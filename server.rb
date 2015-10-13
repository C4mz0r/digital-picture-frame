require 'socket'
require 'colorize'
CRLF = "\r\n"
FRAMEFILE = "picture.html"
SERVERROOT = File.expand_path(File.dirname(__FILE__))
$filter = ""


def respond_to_request(request, folder="")
	response = ""
	
	split_request = request.split

	if split_request[0] != "GET"
		puts "Unsupported command.  This server only supports GET commands"
		return
	end
		
	puts "Found #{split_request[1]}".colorize(:blue)	

	if split_request[1].include? FRAMEFILE

		Dir.chdir SERVERROOT
		body = read_file(FRAMEFILE)		
		response += "HTTP/1.0 200 OK" + CRLF
		response += "Content-Type: text/html" + CRLF
		response += CRLF
		response += body		
		puts "Going to return the picture.html".colorize(:red)
		$filter = split_request[1].split('?')[1]
		puts "Got #{$filter}"
		return response

	else
		#filter = "c4m" #split_request[1]#.split("|")
		#puts "Will send a filter of #{filter}".colorize(:red)
	
		#puts "Will try to search in #{folder}".colorize(:green)
		Dir.chdir SERVERROOT
		puts "Dir is #{Dir.pwd}".colorize(:yellow)
		random_file = select_random_image(folder, $filter)
		puts "Trying to return #{random_file}".colorize(:green)
		body = ""
		body = read_file(random_file) if random_file != nil				
		response += "HTTP/1.0 200 OK" + CRLF
		response += "Content-Type: text/jpeg" + CRLF
		response += CRLF
		response += body
		puts "Going to return the picture.html".colorize(:red)
		return response
	end

end

# Reads a file into a variable for return to requestor
def read_file(item)
	puts "Trying to return #{item} to requestor"
	content = ""
	File.open(item, "rb") do |f|
		f.each_line do |line|
			content += line
		end
	end
	content
end

def select_random_image(folder, filter="")
	Dir.chdir folder
	selected_file = ""
	if !filter.nil?
		selected_file = Dir.glob("**/*").select { |f| f.end_with?(".jpg") and f.include?(filter) }.sample
	else
		selected_file = Dir.glob("**/*").select { |f| f.end_with?(".jpg") }.sample
	end
	puts "The random image is #{selected_file}".colorize(:orange)
	return selected_file
end

puts "Enter the server IP address (or localhost if just using locally)"
ip_address = gets.chomp
ip_address = "localhost" if ip_address.empty?
puts "Enter the directory to limit searches within"
directory  = gets.chomp

server = TCPServer.open(ip_address, 2000)					# listen on port 2000 for client to connect
loop do
	client = server.accept					# wait for a client to connect
	request = ""
	while ( line = client.gets  )		
		request += line
		if request =~ /#{CRLF}#{CRLF}$/ 
			break
		end
	end

	response = respond_to_request(request, directory)		# parse out the request and respond to it (body is optional)
	client.puts response
	client.close
end



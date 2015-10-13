require 'socket'
CRLF = "\r\n"

# Respond to a request
# Returns the response
def respond_to_request(request)
	response = ""
	
	begin
		puts "Received request: #{request}"
		desired_folder = parse_folder_from_request(request)
		puts "Searching for random image file"	
		#Example:  body = read_file(select_random_image("/home/me/Desktop"))
		body = read_file(select_random_image(desired_folder))		
		response += "HTTP/1.0 200 OK" + CRLF
		response += "Content-Type: image/jpeg" + CRLF		
		response += "Content-Length: #{body.length}" + CRLF
		response += CRLF # HTTP convention is a blank line between headers and body
		response += body
	rescue
		puts "Could not find any item"
		response = "HTTP/1.0 404 Not Found" + CRLF
	end

	return response
end

def parse_folder_from_request(request)
	puts "#{request[0]}"#.colorize(:green)
	folder = request.match('.*f=(.*) HTTP')[1]
	puts "Found folder = #{folder}"#.colorize(:red)
	raise if folder.nil?
	folder
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

def select_random_image(folder)
	Dir.chdir folder
	Dir.glob("**/*").select { |f| f.end_with?(".jpg") }.sample
end

server = TCPServer.open(2000)					# listen on port 2000 for client to connect
loop do
	client = server.accept					# wait for a client to connect
	request = ""
	while ( line = client.gets  )		
		request += line
		if request =~ /#{CRLF}#{CRLF}$/ 
			break
		end
	end

	response = respond_to_request(request)		# parse out the request and respond to it (body is optional)
	client.puts response
	client.close
end



require 'socket'
#require 'colorize'
require 'uri'
CRLF = "\r\n"
FRAMEFILE = "picture.html"
SERVERROOT = File.expand_path(File.dirname(__FILE__))
#$filter = ""

class PictureServer

    private

	def initialize(ip_address="localhost", port=2000, directory)
		@server = TCPServer.open(ip_address, port) # listen on specified port for client to connect
		@directory = directory
		listen
	end

	def listen
		loop do
			client = @server.accept		  # wait for a client to connect
			request = ""
			while ( line = client.gets )		
				request += line
				if request =~ /#{CRLF}#{CRLF}$/ 
					break
				end
			end

			response = respond_to_request(request, @directory)		# parse out the request and respond to it (body is optional)
			client.puts response
			client.close
		end
	end

	def respond_to_request(request, folder="")
		response = ""				
		split_request = request.split

		if split_request[0] != "GET"
			puts "Unsupported command.  This server only supports GET commands"
			return
		end
		
		puts "Found #{split_request[1]}"#.colorize(:blue)	

		if split_request[1].include? FRAMEFILE

			Dir.chdir SERVERROOT
			body = FileSelector.read_file(FRAMEFILE)		
			response += "HTTP/1.0 200 OK" + CRLF
			response += "Content-Type: text/html" + CRLF
			response += CRLF
			response += body		
			puts "Going to return the picture.html"
			@filter = split_request[1].split('?')[1] #unescape makes sure we can query with spaces, etc.
			@filter = URI.unescape(@filter) if !@filter.nil?
			puts "Got #{@filter}"
			return response

		else
			Dir.chdir SERVERROOT
			puts "Dir is #{Dir.pwd}"
			random_file = FileSelector.select_random_image(folder, @filter)
			puts "Trying to return #{random_file}"
			body = ""
			body = FileSelector.read_file(random_file) if random_file != nil				
			response += "HTTP/1.0 200 OK" + CRLF
			response += "Content-Type: text/jpeg" + CRLF
			response += CRLF
			response += body
			puts "Going to return the jpg file"
			return response
		end

	end
end


class FileSelector
	@@filelist_cache = nil;
	@@filtered_filelist = nil;

	# Reads a file into a variable for return to requestor
	def self.read_file(item)
		puts "Trying to return #{item} to requestor"
		content = ""
		File.open(item, "rb") do |f|
			f.each_line do |line|
				content += line
			end
		end
		content
	end

	def self.select_random_image(folder, filter="")
		Dir.chdir folder
		selected_file = ""
		
		# cache the file list, so we don't need to keep creating it each time
		@@filelist_cache ||= Dir.glob("**/*").select{ |f| f.end_with?(".jpg") }	
		
		# note:  since we are using regex, the | supplied in url works as 'or' when used in the regex
		if !filter.nil?
			@@filtered_filelist = @@filelist_cache.select{ |f| /#{filter}/.match(f) }
		end

		selected_file = (filter.nil? ? @@filelist_cache : @@filtered_filelist).sample

		puts "The random image is #{selected_file}"
		return selected_file
	end
end



puts "Enter the server IP address (or localhost if just using locally)"
ip_address = gets.chomp
ip_address = "localhost" if ip_address.empty?
puts "Enter the directory to limit searches within"
directory  = gets.chomp

p = PictureServer.new(ip_address, 2000, directory)




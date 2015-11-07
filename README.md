# digital-picture-frame
A simple web server to serve up random content from a directory, similar to a digital picture frame

How to use it:
- Run the server.rb file (e.g. ruby server.rb)
- Specify your computer's IP or just press enter to use localhost.  (I found that if I wanted to access this server from other machines, that I needed to be able to specify IP.)
- Type the path to limit searches within (e.g. perhaps "C:\Users\Public" on Windows, or perhaps something like "/home" on Linux)
- Now connect your browser to http://server_name:2000/picture.html which will start looking recursively within the path specified above
- Every 10 seconds the browser will request a new image, similar to a digital picture frame
- You can also specify a filter on the url, if they would like to narrow down the search folders

For example:
Suppose server has been set up and is only looking in "C:\Users\Public" (and nested folders) for photos

Pointing the browser to localhost:2000/picture.html would then serve up these photos randomly

Suppose, you know you have a folder called "Animals" somewhere in the path, and you'd like to limit the search to this without reinitializing the server.  From the client (browser), you can tack on a directory substring to limit the search: e.g. localhost:2000/picture.html?Anim would only show images that were in nested directories that have the string "Anim" somewhere in them.  Keep in mind, "Anim" would match directories like "Animals", "Animation", etc.

Nov-6-2015 - "Or" filtering is now added, to use it specify | within the search string on the URL.  For example:  localhost:2000/picture.html?cats|dogs would show files that have either cats or dogs somewhere within their name or path.


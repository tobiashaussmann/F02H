// Load the http module to create an http server
var http = require('http');

// Configure our http server to respond
var server = http.createServer(function (request, response) {
  response.writeHead(200, {"Content-Type": "text/plain"});
  response.end("Hello World\n");
});

//Listen on port 8000
server.listen(8000);

//Put friendly message on the terminal
console.log("Server running at http://127.0.0.1:8000/");

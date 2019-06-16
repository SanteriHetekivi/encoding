#!/usr/bin/python
from http.server import BaseHTTPRequestHandler, HTTPServer
import subprocess
import os
import getpass

PORT_NUMBER = 80


class myHandler(BaseHTTPRequestHandler):

    # Handler for the GET requests
    def do_GET(self):
        try:
            code = subprocess.call(
                ["/app/make_html_status.sh"]
            )
            if code is 0:
                with open('/app/www/status.html', 'r') as file:
                    html = file.read()
            else:
                html = "Error code: {}".format(code)
        except Exception as e:
            html = "Error: {}".format(str(e))
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(bytes(html, "utf-8"))
        return

    def do_POST(self):
        data = "OK"
        response_code = 200
        try:
            subprocess.Popen(
                ["killall HandBrakeCLI; killall encode.sh; /app/encode.sh"], shell=True, stdin=None, stdout=None, stderr=None, close_fds=True)
        except Exception as e:
            data = "Error: {}".format(str(e))
        if data is not "OK":
            response_code = 500
        # Begin the response
        self.send_response(response_code)
        self.end_headers()
        self.wfile.write(bytes(data, "utf-8"))


try:
    # Create a web server and define the handler to manage the
    # incoming request
    server = HTTPServer(('', PORT_NUMBER), myHandler)
    print('Started {}'.format(PORT_NUMBER))

    # Wait forever for incoming htto requests
    server.serve_forever()

except KeyboardInterrupt:
    print('Shutting down')
    server.socket.close()

# Gemini diagnostics
https://github.com/michael-lazar/gemini-diagnostics
```
$ ./gemini-diagnostics 
Running server diagnostics check against localhost:1965
...

[IPv4Address] Establish a connection over an IPv4 address
Looking up IPv4 address for 'localhost'
  ✓ '127.0.0.1'
Attempting to connect to 127.0.0.1:1965
  ✓ Successfully established connection

[IPv6Address] Establish a connection over an IPv6 address
Looking up IPv6 address for 'localhost'
  ✓ '::1'
Attempting to connect to [::1]:1965
  ✓ Successfully established connection

[TLSVersion] Server must negotiate at least TLS v1.2, ideally TLS v1.3
Checking client library
  'OpenSSL 3.0.2 15 Mar 2022'
Determining highest supported TLS version
/home/bandura/gemini-diagnostics/./gemini-diagnostics:179: DeprecationWarning: ssl.PROTOCOL_TLS is deprecated
  context = ssl.SSLContext(ssl.PROTOCOL_TLS)
  ✓ Negotiated TLSv1.3

[TLSClaims] Certificate claims must be valid
Checking "Not Valid Before" timestamp
  ✓ 2022-01-01 20:31:00 UTC
Checking "Not Valid After" timestamp
  ✓ 9999-12-31 23:59:59 UTC
Checking subject claim matches server hostname
  {'subject': ((('commonName', 'localhost'),),), 'subjectAltName': (('DNS', 'localhost'),)}
/home/bandura/gemini-diagnostics/./gemini-diagnostics:330: DeprecationWarning: ssl.match_hostname() is deprecated
  ssl.match_hostname(cert_dict, self.args.host)
  ✓ Hostname 'localhost' matches claim

[TLSVerified] Certificate should be self-signed or have a trusted issuer
Connecting over verified SSL socket
  ✓ Self-signed TLS certificate detected

[TLSCloseNotify] Server should send a close_notify alert before closing the connection
Checking for close_notify TLS signal
/home/bandura/gemini-diagnostics/./gemini-diagnostics:363: DeprecationWarning: ssl.PROTOCOL_TLS is deprecated
  context = ssl.SSLContext(ssl.PROTOCOL_TLS)
Request URL
  'gemini://localhost/\r\n'
Response header
  '20 text/gemini\r\n'
  ✓ TLS close_notify signal was received successfully

[TLSRequired] Non-TLS requests should be refused
Sending non-TLS request
  ✓ ConnectionResetError(104, 'Connection reset by peer')

[ConcurrentConnections] Server should support concurrent connections
Attempting to establish two connections
  Opening socket 1
  Opening socket 2
  Closing socket 2
  Closing socket 1
  ✓ Concurrent connections supported

[ResponseFormat] Validate the response header and body for the root URL
Request URL
  'gemini://localhost/\r\n'
Response header
  '20 text/gemini\r\n'
Status should return a success code (20 SUCCESS)
  ✓ Received status of '20'
There should be a single space between <STATUS> and <META>
  ✓ '0 t'
Mime type should be "text/gemini"
  ✓ 'text/gemini'
Header should end with "\r\n"
  ✓ '\r\n'
Body should be non-empty
  ✓ '# It works!\nTest another thing...\n'
Body should use consistent line endings
  ✓ All lines end with \n

[HomepageNoRedirect] The root URL should return the same resource with or without the trailing slash.
Request URL
  'gemini://localhost/\r\n'
Response header
  '20 text/gemini\r\n'
Status should return a success code (20 SUCCESS)
  ✓ Received status of '20'

[PageNotFound] Request a gemini URL that does not exist
Request URL
  'gemini://localhost/09pdsakjo73hjn12id78\r\n'
Response header
  '51 The requested resourse was not found.\r\n'
Status should return code 51 (NOT FOUND)
  ✓ '51'
Header should end with "\r\n"
  ✓ '\r\n'
Body should be empty
  ✓ ''

[RequestMissingCR] A request without a <CR> should timeout
Request URL
  'gemini://localhost/\n'
Response header
  '20 text/gemini\r\n'
No response should be received
  x '20'

[URLIncludePort] Send the URL with the port explicitly defined
Request URL
  'gemini://localhost:1965/\r\n'
Response header
  '20 text/gemini\r\n'
Status should return a success code (20 SUCCESS)
  ✓ Received status of '20'

[URLSchemeMissing] A URL without a scheme should result in a 59 Bad Request
Request URL
  '//localhost/\r\n'
Response header
  '59 No scheme was passed in the requested URI. Therefore, the request is not processed.\r\n'
Status should return a failure code (59 BAD REQUEST)
  ✓ Received status of '59'

[URLByIPAddress] Send the URL using the IPv4 address
Request URL
  'gemini://127.0.0.1:1965/\r\n'
Response header
  '53 A domain was requested which was not found on the server. Therefore, the request could not be processed.\r\n'
Verify that the status matches your desired behavior
  ✓ '53'

[URLInvalidUTF8Byte] Send a URL containing a non-UTF8 byte sequence
Request URL
  'gemini://localhost/\udcdc\r\n'
Response header
  '59 URI must be ascii only "gemini://localhost/\\xDC"\r\n'
Connection should either drop, or return 59 (BAD REQUEST)
  ✓ Received status of '59'

[URLMaxSize] Send a 1024 byte URL, the maximum allowed size
Request URL
  'gemini://localhost/000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\r\n'
Response header
  '51 The requested resourse was not found.\r\n'
Status should return code 51 (NOT FOUND)
  ✓ '51'

[URLAboveMaxSize] Send a 1025 byte URL, above the maximum allowed size
Request URL
  'gemini://localhost/0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\r\n'
Response header
  '59 The URI is longer than the allowed 1024 characters. Therefore, the request is rejected.\r\n'
Connection should either drop, or return 59 (BAD REQUEST)
  ✓ Received status of '59'

[URLWrongPort] A URL with an incorrect port number should be rejected
Request URL
  'gemini://localhost:443/\r\n'
Response header
  '53 A recourse was requested on a port (443) which does not belong to this server. The request is therefore aborted.\r\n'
Status should return a failure code (53 PROXY REQUEST REFUSED)
  ✓ Received status of '53'

[URLWrongHost] A URL with a foreign hostname should be rejected
Request URL
  'gemini://wikipedia.org/\r\n'
Response header
  '53 A domain was requested which was not found on the server. Therefore, the request could not be processed.\r\n'
Status should return a failure code (53 PROXY REQUEST REFUSED)
  ✓ Received status of '53'

[URLSchemeHTTP] Send a URL with an HTTP scheme
Request URL
  'http://localhost/\r\n'
Response header
  '53 A recourse was requested on a port (80) which does not belong to this server. The request is therefore aborted.\r\n'
Status should return a failure code (53 PROXY REQUEST REFUSED)
  ✓ Received status of '53'

[URLSchemeHTTPS] Send a URL with an HTTPS scheme
Request URL
  'https://localhost/\r\n'
Response header
  '53 A recourse was requested on a port (443) which does not belong to this server. The request is therefore aborted.\r\n'
Status should return a failure code (53 PROXY REQUEST REFUSED)
  ✓ Received status of '53'

[URLSchemeGopher] Send a URL with a Gopher scheme
Request URL
  'gopher://localhost/\r\n'
Response header
  '53 Scheme `gopher` has been sent. However, this is a Gemini server which expects the scheme `gemini://`.\r\n'
Status should return a failure code (53 PROXY REQUEST REFUSED)
  ✓ Received status of '53'

[URLEmpty] Empty URLs should not be accepted by the server
Request URL
  '\r\n'
Response header
  '59 No request line was sent.\r\n'
Status should return a failure code (59 BAD REQUEST)
  ✓ Received status of '59'

[URLRelative] Relative URLs should not be accepted by the server
Request URL
  '/\r\n'
Response header
  '59 No scheme was passed in the requested URI. Therefore, the request is not processed.\r\n'
Status should return a failure code (59 BAD REQUEST)
  ✓ Received status of '59'

[URLInvalid] Random text should not be accepted by the server
Request URL
  'Hello Gemini!\r\n'
Response header
  '59 bad URI(is not URI?): "Hello Gemini!"\r\n'
Status should return a failure code (59 BAD REQUEST)
  ✓ Received status of '59'

[URLDotEscape] A URL should not be able to escape the root using dot notation
Request URL
  'gemini://localhost/../../\r\n'
Response header
  '52 An invalid path was sent, which would have caused the server to misbehave. Therefore, the request was aborted.\r\n'
Status should return a failure code (5X PERMANENT FAILURE)
  ✓ Received status of '52'

Done!
Failed 1 check: RequestMissingCR
1 check returned None: URLByIPAddress
```
07.08.2022

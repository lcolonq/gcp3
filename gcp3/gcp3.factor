USING: accessors http http.server io.backend io.pathnames io.servers
kernel logging logging.server namespaces prettyprint ;
IN: gcp3

"/tmp" \ log-root set-global

TUPLE: gcp3-responder foobar ;
M: gcp3-responder call-responder* ( path responder -- response )
    drop
    unparse \ gcp3-responder NOTICE log-message 
    <response> 200 >>code "hello computer" >>body
    ;

: serve ( -- s )
    "gcp3" [
        gcp3-responder new main-responder set-global
        8080 httpd
    ] with-logging
    ;

: blocking-serve ( -- )
    serve wait-for-server
    ;

MAIN: blocking-serve

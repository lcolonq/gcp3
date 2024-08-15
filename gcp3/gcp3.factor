USING: accessors combinators http http.server images.bitmap io.backend
io.encodings.binary io.pathnames io.servers io.streams.byte-array
kernel logging logging.server math mrtwr namespaces prettyprint ;
IN: gcp3

"/tmp" \ log-root set-global

SYMBOL: mrgreen
load-mrgreen mrgreen set-global

TUPLE: gcp3-responder gcp3-quotient ;
: gcp3-log ( x -- )
    unparse \ gcp3-responder NOTICE log-message 
    ;
M: gcp3-responder call-responder* ( path responder -- response )
    drop
    dup gcp3-log
    { { [ dup { } = ]
        [ drop <response>
          200 >>code
          "text/plain" >>content-type
          "hello this is index" >>body
        ]
      }
      { [ dup { "mr" } = ]
        [ drop <response>
          200 >>code
          binary >>content-encoding
          "image/bmp" >>content-type
          mrgreen get-global
          [ rgb>hsv [ 35 + 256 rem ] change-h hsv>rgb ] map-pixels
          image>bmp-bytes >>body
        ]
      }
      [ drop <response> 404 >>code "not found :3" >>body "text/plain" >>content-type ]
    } cond
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

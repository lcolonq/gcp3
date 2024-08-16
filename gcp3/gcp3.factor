USING: accessors combinators gcp3.mrtwr http http.server images.bitmap
io.backend io.encodings.binary io.encodings.utf8 io.files io.pathnames
io.servers io.streams.byte-array kernel logging logging.server math
namespaces prettyprint ;
IN: gcp3

"/tmp" \ log-root set-global

SYMBOL: mrgreen
load-mrgreen mrgreen set-global

:: gcp3-respond-image ( path -- response )
    <response>
    200 >>code
    binary >>content-encoding
    "image/png" >>content-type
    path binary file-contents >>body
    ;

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
          "text/html" >>content-type
          "assets/index.html" utf8 file-contents >>body
        ]
      }
      { [ dup { "css" } = ]
        [ drop <response>
          200 >>code
          "text/css" >>content-type
          "assets/main.css" utf8 file-contents >>body
        ]
      }
      { [ dup { "mrgreen" } = ] [ drop "assets/mrgreen.png" gcp3-respond-image ] }
      { [ dup { "mrblue" } = ] [ drop "assets/mrblue.png" gcp3-respond-image ] }
      { [ dup { "mrred" } = ] [ drop "assets/mrred.png" gcp3-respond-image ] }
      { [ dup { "mryellow" } = ] [ drop "assets/mryellow.png" gcp3-respond-image ] }
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

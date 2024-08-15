USING: accessors arrays combinators images images.bitmap images.png io
io.encodings.binary io.files io.streams.byte-array kernel math
namespaces prettyprint sequences ;
IN: mrtwr

TUPLE: hsv-pixel h s v ;

: load-mrgreen ( -- image )
    "assets/mrgreen.png" binary [ input-stream get load-png loading-png>image ] with-file-reader
    ;

: image>bmp-bytes ( image -- bytes )
    binary [ output-bmp ] with-byte-writer
    ;

: write-bmp-file ( image path -- )
    binary [ output-bmp ] with-file-writer
    ;

:: rgb>hsv ( pixel -- hsv-pixel )
    0 pixel nth :> r
    1 pixel nth :> g
    2 pixel nth :> b
    { r g b } supremum >fixnum :> v
    v { r g b } infimum - :> d
    v 0 = [ 0 ] [ d 255 * v / ] if >fixnum :> s
    v 0 = s 0 = or [ 0 ] [
        { { [ v r = ] [ g b - 43 * d / 0 + ] }
          { [ v g = ] [ b r - 43 * d / 85 + ] }
          [ r g - 43 * d / 171 + ]
        } cond
    ] if >fixnum :> h
    hsv-pixel new h >>h s >>s v >>v
    ;

:: hsv>rgb ( hsv -- pixel )
    hsv s>> 0 = [ hsv v>> dup dup 3array ] [
        hsv h>> 43 / >fixnum :> region
        hsv h>> region 43 * - 6 * >fixnum :> remainder
        hsv v>> 255 hsv s>> - * -8 shift :> p
        hsv v>> 255 hsv s>> remainder * -8 shift - * -8 shift :> q
        hsv v>> 255 hsv s>> 255 remainder - * -8 shift - * -8 shift :> t_
        { { [ region 0 = ] [ hsv v>> t_ p 3array ] }
          { [ region 1 = ] [ q hsv v>> p 3array ] }
          { [ region 2 = ] [ p hsv v>> t_ 3array ] }
          { [ region 3 = ] [ p q hsv v>> 3array ] }
          { [ region 4 = ] [ t_ p hsv v>> 3array ] }
          [ hsv v>> p q 3array ]
        } cond
    ] if
    ;

:: map-pixels ( image quot: ( pixel -- pixel ) -- image )
    image [
        quot call( pixel -- pixel ) -rot image set-pixel-at
    ] each-pixel
    image
    ;

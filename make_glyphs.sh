clear
# fontsize=18
fontsize=20
maxWidth=16
maxHeight=16
outFormat=bmp
font=ArialHebrew-Bold-02.ttf
# font="./Arial_Rounded_Bold.ttf"
# font="./Sudo.ttf"



commonParams="-background black -fill white -gravity NorthWest +antialias"
borderParams="-bordercolor black -border 1x1"
rm -rf ./BMP/
mkdir ./BMP
echo '{"header":[78,69,90,75,8,255,255,255,255,255,1,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255],"version":8}' > ./BMP/font_info.json


function symbolsRange {
  current=$(printf '%d' $1)
  stop=$(printf '%d' $2)
  param3=$3
  param4=$4
  ### https://stackoverflow.com/questions/3953645/ternary-operator-in-bash#3953712
  fontLocalSize=${param3:-$fontsize}
  fontLocalName=${param4:-$font}
  echo using size $fontLocalSize and font $fontLocalName
  while test "$current" -le "$stop"; do
    hex=$(printf "%04X" "$current")
    symbol=$(printf "\u"$hex)
    echo "$symbol" $hex
    process "$symbol" $hex $fontLocalSize $fontLocalName
    current=$((current+1))
  done
}


function process {
    currentSymbol="$1"
    symbolCode=$2
    fSize=$3
    fName=$4
    fParams="-pointsize $fSize -font $fName"

    label="label:"\\"$currentSymbol"
    sizes=$(convert $commonParams $fParams $label $borderParams -trim  info:- 2>/dev/null)
    trimmedSize=$(echo $sizes|awk '{ print $3 }')
    symbolWidth=$(echo $trimmedSize| awk -F'x' '{ print $1 }')
    Width2=$(printf "%01X" $(($symbolWidth-1)))

    symbolHeight=$(echo $trimmedSize| awk -F'x' '{ print $2 }')
    canvas=$(echo $sizes|awk '{ print $4 }')
    cXShift=$(echo $canvas| awk -F'[+x]' '{ print $3 }')
    cYShift=$(echo $canvas| awk -F'[+x]' '{ print $4 }')


    if [[ "$trimmedSize" = '1x1' ]]; then
      echo $symbolCode 'no glyph'
    else
      # if (( $cYShift > 4 )); then
      #   cYShift=4
      # fi
    # top=$cYShift
    top=$(($cYShift-0))
    topHex=$(printf "%01X" $top)
    # TODO find out a magick correction number to decrease topHex parameter (last digit in filename)

      # IM can not produce BMP's at depth levels other than 8.  However you can
      #   use NetPBM image processing set to do the final conversion to other depth
      #   levels (This needs at least a Q16 version of IM)...
      #       convert image +matte -colors 16 ppm:- |\
      #         pnmdepth 4 | ppm2bmp > image.bmp
      # https://www.imagemagick.org/Usage/formats/#bmp

      cropPage="$borderParams -crop 16x16+$cXShift+$top -set page 16x16+0+0"
      firstTransform="-flatten -colors 4 +dither -type bilevel  MONO:"
      secondTransform="convert -size 16x16 MONO:-"
      generatedFilename="$hex"_"$Width2""$topHex"

      convert $commonParams $fParams $label $cropPage \
        $firstTransform|$secondTransform BMP3:BMP/$generatedFilename.bmp

    fi
}


############ Hebrew start
# symbolsRange "0x0591" "0x05C7"
# symbolsRange "0x05D0" "0x05EA"
# symbolsRange "0xFB1D" "0xFB36"
# symbolsRange "0xFB38" "0xFB3C"
# symbolsRange "0xFB3E" "0xFB3E"
# symbolsRange "0xFB40" "0xFB41"
# symbolsRange "0xFB43" "0xFB44"
symbolsRange "0xFB46" "0xFB4F"
############ end

############ askii
symbolsRange "0x21" "0x2F" 22 Arial_Rounded_Bold.ttf
symbolsRange "0x30" "0x39" 22 Arial_Rounded_Bold.ttf
symbolsRange "0x40" "0x7E" 22 Arial_Rounded_Bold.ttf
############ 
symbolsRange "0xC0" "0x1BF" 18 Arial_Rounded_Bold.ttf

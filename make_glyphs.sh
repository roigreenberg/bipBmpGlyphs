clear
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

function codeFromSymbol {
  printf "%x\n" \'A
}

function symbolsInString {
  charsList=$1
  param3=$2
  param4=$3
  fontLocalSize=${param3:-$fontsize}
  fontLocalName=${param4:-$font}
  echo using size $fontLocalSize and font $fontLocalName
  for (( i=0; i<${#charsList}; i++ )); do
  symbol=${charsList:$i:1}
  hex=$(printf "%04X" \'$symbol)
    echo "$symbol" $hex
    process "$symbol" $hex $fontLocalSize $fontLocalName
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
# symbolsRange "0xFB46" "0xFB4F"
############ end

# symbolsRange "0x21" "0x2F" 18 Arial_Black.ttf
symbolsRange "0x30" "0x39" 19 Arial_Black.ttf
# ############ ascii
# symbolsRange "0x40" "0x40" 16 Arial_Black.ttf
# symbolsRange "0x41" "0x56" 18 Arial_Black.ttf
# symbolsRange "0x57" "0x5F" 18 Arial_Black.ttf
# symbolsRange "0x60" "0x7E" 17 Arial_Black.ttf
# ############  Czech
# symbolsRange "0xC1" "0xC1" 17 Arial_Black.ttf
# symbolsRange "0xC9" "0xC9" 17 Arial_Black.ttf
# symbolsRange "0xCD" "0xCD" 17 Arial_Black.ttf
# symbolsRange "0xD3" "0xD3" 17 Arial_Black.ttf
# symbolsRange "0xDA" "0xDA" 17 Arial_Black.ttf
# symbolsRange "0xDD" "0xDD" 17 Arial_Black.ttf
# symbolsRange "0xE1" "0xE1" 17 Arial_Black.ttf
# symbolsRange "0xE9" "0xE9" 17 Arial_Black.ttf
# symbolsRange "0xED" "0xED" 17 Arial_Black.ttf
# symbolsRange "0xF3" "0xF3" 17 Arial_Black.ttf
# symbolsRange "0xFA" "0xFA" 17 Arial_Black.ttf
# symbolsRange "0xFD" "0xFD" 17 Arial_Black.ttf
# symbolsRange "0x10C" "0x10F" 17 Arial_Black.ttf
# symbolsRange "0x11A" "0x11B" 17 Arial_Black.ttf
# symbolsRange "0x147" "0x148" 17 Arial_Black.ttf
# symbolsRange "0x158" "0x159" 17 Arial_Black.ttf
# symbolsRange "0x160" "0x161" 17 Arial_Black.ttf
# symbolsRange "0x164" "0x165" 17 Arial_Black.ttf
# symbolsRange "0x16E" "0x16F" 17 Arial_Black.ttf
# symbolsRange "0x17D" "0x17E" 17 Arial_Black.ttf
# #################### russian
# symbolsRange "0x410" "0x42F" 18 Arial_Black.ttf
# symbolsRange "0x430" "0x44F" 18 Arial_Black.ttf
# #################### Ukrainian, Serbian, Byelorussian
# symbolsRange "0x400" "0x40F" 18 Arial_Black.ttf
# symbolsRange "0x450" "0x45F" 18 Arial_Black.ttf

symbolsInString QAZWSXEDC 19 Arial_Black.ttf
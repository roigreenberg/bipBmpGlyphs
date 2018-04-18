# fontsize=18
fontsize=22
maxWidth=16
maxHeight=16
outFormat=bmp
font=ArialHebrew-Bold-02.ttf
# font="./Arial_Rounded_Bold.ttf"
# font="./Sudo.ttf"
rm -rf ./BMP/
mkdir ./BMP



function symbolsRange {
  current=$(printf '%d' $1)
  stop=$(printf '%d' $2)
  while test "$current" -le "$stop"; do
    hex=$(printf "%04X" "$current")
    symbol=$(printf "\u"$hex)
    process $symbol $hex
    current=$((current+1))
  done
}

function process {
    # echo $1 $2
    currentSymbol=$1
    symbolCode=$2
    sizes=$(convert -background black -fill white -pointsize $fontsize -gravity center +antialias -font $font label:"$currentSymbol" -trim  info:- 2>/dev/null)
    trimmedSize=$(echo $sizes|awk '{ print $3 }')
    symbolWidth=$(echo $trimmedSize| awk -F'x' '{ print $1 }')
    # Width=$(printf "%01X" "$symbolWidth")
    Width2=$(printf "%01X" $(($symbolWidth+1)))
    # echo original $Width plus one $Width2

    symbolHeight=$(echo $trimmedSize| awk -F'x' '{ print $2 }')
    canvas=$(echo $sizes|awk '{ print $4 }')
    cXShift=$(echo $canvas| awk -F'[+x]' '{ print $3 }')
    cYShift=$(echo $canvas| awk -F'[+x]' '{ print $4 }')


    if [[ "$trimmedSize" = '1x1' ]]; then
      echo $symbolCode 'no glyph'
    else
      echo $symbolCode "( $symbolWidth x $symbolHeight )"  shifted $cXShift right and $cYShift down $currentSymbol
      if (( $cYShift > 4 )); then
        cYShift=4
      fi
      # crop $cYShift from top, $cXShift from left, $symbolWidth, $symbolHeight<=16 and save   (-crop +top+left +repage)
      convert -background black -fill white -pointsize $fontsize -gravity center +antialias -font $font label:"$currentSymbol"  -crop 16x16+$cYShift+$cXShift +repage -set page 16x16+0+0 -flatten   BMP/"$hex"_"$Width2""$cYShift".$outFormat
    fi
}

symbolsRange "0x0591" "0x05C7"
symbolsRange "0x05D0" "0x05EA"
symbolsRange "0xFB1D" "0xFB36"
symbolsRange "0xFB38" "0xFB3C"
symbolsRange "0xFB3E" "0xFB3E"
symbolsRange "0xFB40" "0xFB41"
symbolsRange "0xFB43" "0xFB44"
symbolsRange "0xFB46" "0xFB4F"

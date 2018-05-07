# fontsize=18
fontsize=20
maxWidth=16
maxHeight=16
outFormat=bmp
font=ArialHebrew-Bold-02.ttf
# font="./Arial_Rounded_Bold.ttf"
# font="./Sudo.ttf"



commonParams="-background black -fill white -pointsize $fontsize -gravity West +antialias -font $font"
borderParams="-bordercolor black -border 1x1"
echo $commonParams
rm -rf ./BMP/
mkdir ./BMP
echo '{"header":[78,69,90,75,8,255,255,255,255,255,1,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255],"version":8}' > ./BMP/font_info.json


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
    currentSymbol=$1
    symbolCode=$2
    sizes=$(convert $commonParams label:"$currentSymbol" $borderParams -trim  info:- 2>/dev/null)
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
      echo $symbolCode $currentSymbol y: $cYShift   
      # shifted $cXShift right and $cYShift down
      # echo $symbolCode "($symbolWidth x $symbolHeight)" $currentSymbol
      # if (( $cYShift > 4 )); then
      #   cYShift=4
      # fi
    # top=$cYShift
    top=$(($cYShift-4))
    topHex=$(printf "%01X" $top)

    #  crop from the top isn't working very well yet....

      # IM can not produce BMP's at depth levels other than 8.  However you can
      #   use NetPBM image processing set to do the final conversion to other depth
      #   levels (This needs at least a Q16 version of IM)...
      #       convert image +matte -colors 16 ppm:- |\
      #         pnmdepth 4 | ppm2bmp > image.bmp
      # https://www.imagemagick.org/Usage/formats/#bmp

      convert $commonParams label:"$currentSymbol"  $borderParams -crop 16x16+$cXShift+$top -set page 16x16+0+0 -flatten -colors 4 +dither -type bilevel  MONO:|convert -size 16x16 MONO:-  BMP3:BMP/"$hex"_"$Width2""$topHex".bmp
      convert $commonParams label:"$currentSymbol"  $borderParams -crop 16x16+$cXShift+0 -set page 16x16+0+0 -flatten -colors 4 +dither -type bilevel  MONO:|convert -size 16x16 MONO:-  BMP3:BMP/"$hex"_"$Width2"0.bmp

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

############ askii
symbolsRange "0x29" "0x2F"
symbolsRange "0x59" "0x5D"
symbolsRange "0x30" "0x39"
# 5c "\" causing error ??? escaping problem
# 2a - the same
# symbolsRange "0x2B" "0x5B"
# symbolsRange "0x5D" "0x5B"
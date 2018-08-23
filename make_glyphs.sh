#!/usr/bin/env bash
clear
fontsize=20
maxWidth=16
maxHeight=16
outFormat=bmp
font=ArialHebrew-Bold-02.ttf
# font="./Arial_Rounded_Bold.ttf"
# font="./Sudo.ttf"
langName=""

out_path=$1

commonParams="-background black -fill white -gravity NorthWest +antialias"
borderParams="-bordercolor black -border 1x1"
#rm -rf ./$out_path/
mkdir ./$out_path
echo '{"header":[78,69,90,75,8,255,255,255,255,255,1,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255],"version":8}' > ./$out_path/font_info.json

function codepoint2Utf {
  local utfDecimal=$1
  local result=''
  local bytes=0
  if [[ "$utfDecimal" -lt 128 ]]; then
    result="$(printf '\\x%X' $utfDecimal)"
    utfDecimal=0
  fi
  while test "$utfDecimal" -gt 0; do
    result="$(printf '\\x%X' $(($utfDecimal & 63 |128)))$result"
    bytes=$(($bytes+1))
    utfDecimal=$(($utfDecimal>>6 )) 
    if [[ $utfDecimal -lt 128 ]]; then
      if [[ $bytes -eq 2 ]]; then
        result="$(printf '\\x%X' $(($utfDecimal |224)))$result"
      fi
      if [[ $bytes -eq 1 ]]; then
        result="$(printf '\\x%X' $(($utfDecimal |192)))$result"
      fi
      utfDecimal=$(($utfDecimal>>6 )) 
    fi
  done
  echo $result
}

function symbolsRange {
    current=$(printf '%d' $1)
    stop=$(printf '%d' $2)
    param3=$3
    param4=$4
    ### https://stackoverflow.com/questions/3953645/ternary-operator-in-bash#3953712
    fontLocalSize=${param3:-$fontsize}
    fontLocalName=${param4:-$font}
    echo using size $fontLocalSize and font $fontLocalName
    local YCORR=$(getVertCorrection 0 0030 $fontLocalSize $fontLocalName)
    echo standart shift is $YCORR
    while test "$current" -le "$stop"; do
        hexPadded=$(printf "%04X" "$current")
        hex=$(printf "%04X" "$current")
        # symbol=$(printf "\x$hex")
        symbol=$(printf $(codepoint2Utf $current))

        # echo -ne '\xd0\xa4' bash 3x way to print utf symbols
        echo "$symbol" $hexPadded
        process "$symbol" $hexPadded $YCORR $fontLocalSize $fontLocalName
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
    local YCORR=$(getVertCorrection 0 0030 $fontLocalSize $fontLocalName)
    echo standart shift is $YCORR
    for (( i=0; i<${#charsList}; i++ )); do
        symbol=${charsList:$i:1}
        hex=$(echo -ne $symbol | iconv -t utf-16be|od -t x1 -A none|sed  's/ //g')
        # hex=$(printf "%04X" \'$symbol)
        # don't work under bash 3.2 high sierra default
        echo "$symbol" $hex
        process "$symbol" $hex $YCORR $fontLocalSize $fontLocalName $langName
    done
}

function getVertCorrection {
    # the main idea is to call this function with symbol 0 or any standart capital letter (no diacritics)
    # to extract standart vertical shift. It will be used as 4 pix from top and others shifts will be relative
    # this one as it used in original fonts
    currentSymbol="$1"
    symbolCode=$2
    fSize=$3
    fName=$4
    fParams="-pointsize $fSize -font $fName"
    label="label:"\\"$currentSymbol"
    sizes=$(convert $commonParams $fParams $label $borderParams -trim  info:- 2>/dev/null)
    canvas=$(echo $sizes|awk '{ print $4 }')
    local YShift=$(echo $canvas| awk -F'[+x]' '{ print $4 }')
    echo $(($YShift-4))
    
}

function process {
    currentSymbol="$1"
    symbolCode=$2
    verticalCorrector=$3
    fSize=$4
    fName=$5
    fParams="-pointsize $fSize -font $fName"

    label="label:"\\"$currentSymbol"
    sizes=$(convert $commonParams $fParams $label $borderParams -trim  info:- 2>/dev/null)
    trimmedSize=$(echo $sizes|awk '{ print $3 }')
    symbolWidth=$(echo $trimmedSize| awk -F'x' '{ print $1 }')
    # it could be wider than 16, so we should limit it to 16
    
    symbolHeight=$(echo $trimmedSize| awk -F'x' '{ print $2 }')
    canvas=$(echo $sizes|awk '{ print $4 }')
    cXShift=$(echo $canvas| awk -F'[+x]' '{ print $3 }')
    cYShift=$(echo $canvas| awk -F'[+x]' '{ print $4 }')


    if [[ "$trimmedSize" = '1x1' ]]; then
        echo $symbolCode 'no glyph'
    else
         topCorrected=4
        # TODO find out a magick correction number to decrease topHex parameter (last digit in filename)
        top=$(($verticalCorrector+4))
        calculatedShift=$(($cYShift+4-($verticalCorrector+4) ))
        normalizedHeight=$(($cYShift-$top+$symbolHeight))
        # echo $currentSymbol $verticalCorrector $cYShift $top $symbolHeight
        if (( $normalizedHeight >16 )) && (( $normalizedHeight > $symbolHeight )); then
          echo '---'
          echo $currentSymbol  $symbolHeight $normalizedHeight
          top=$cYShift
          topCorrected=$calculatedShift
        #   echo '--- standart: '"$(($verticalCorrector+4)) current: $cYShift" 
        fi
        if  (( $top > $cYShift )); then
          echo '--- less ------'
          echo $currentSymbol  $symbolHeight $top \< $cYShift
          top=$cYShift
          topCorrected=$calculatedShift
        #   echo '--- standart: '"$(($verticalCorrector+4)) current: $cYShift" 
        fi
        if (( $symbolWidth >16)); then
            symbolWidth=16
        fi
        if (( $topCorrected < 0)); then
            topCorrected=0
        fi
        Width2=$(printf "%01X" $(($symbolWidth-1)))
        topHex=$(printf "%01X" $topCorrected)
        
        # IM can not produce BMP's at depth levels other than 8.  However you can
        #   use NetPBM image processing set to do the final conversion to other depth
        #   levels (This needs at least a Q16 version of IM)...
        #       convert image +matte -colors 16 ppm:- |\
        #         pnmdepth 4 | ppm2bmp > image.bmp
        # https://www.imagemagick.org/Usage/formats/#bmp
        
        cropPage="$borderParams -crop 16x16+$cXShift+$top -set page 16x16+0+0"
        # cropPage="$borderParams -crop 16x16+$cXShift+$topCorrected -set page 16x16+0+0"
        firstTransform="-flatten -colors 4 +dither -type bilevel  MONO:"
        secondTransform="convert -size 16x16 MONO:-"
        generatedFilename="$hex"_"$Width2""$topHex"
        
        convert $commonParams $fParams $label $cropPage \
        $firstTransform|$secondTransform BMP3:$out_path/$langName/$generatedFilename.bmp
        
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
# symbolsRange "0x30" "0x39" 19 Arial_Black.ttf
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

# symbolsInString "АБВГДЕЗИЙКЛМНОПРСТУФХЦЧЫЭЯ" 19 Arial_Black.ttf
# symbolsInString "ЖШЩЮ" 17 Arial_Black.ttf
# symbolsInString "абвгдезийклмнопрстухцчшщыэюя" 19 Arial_Black.ttf
# symbolsInString "ж" 18 Arial_Black.ttf
# symbolsInString "ф" 17 Arial_Black.ttf
# symbolsInString "jklmoz0yfb" 19 Arial_Black.ttf

function setOutDir {
    langName=$1
    rm -rf ./$out_path/$langName/
    mkdir ./$out_path/$langName
    echo $langName
}

########### Lithuanian
#setOutDir "Lithuanian"
#symbolsInString	"ĄąĖėĘęĮįŲųŪūČčŠšŽž" 16 fonts/arial.ttf

############ Arabic start
#setOutDir "Arabic"
#symbolsRange "0x0600" "0x06FF" 18 fonts/Tahoma_Regular_font.ttf
#symbolsRange "0x0750" "0x077F" 19 fonts/tradbdo.ttf
#symbolsRange "0x08A0" "0x08FF" 19 fonts/tradbdo.ttf
#symbolsRange "0xFB50" "0xFDFF" 19 fonts/tradbdo.ttf

#setOutDir "Arabic_connected"
#symbolsRange "0xFE70" "0xFEFF" 16 fonts/Tahoma_Regular_font.ttf
############# end

########### Georgian
setOutDir "Georgian"
#symbolsRange "0x10A0" "0x10FF" 16 fonts/sylfaen.ttf
symbolsInString	"აბგდევზთიკლმნოპჟრსტუფქღყშჩცძწჭხჯჰჱჲჳჴჵჶჷჸჹჺ჻ჼჽჾჿ" 18 fonts/sylfaen.ttf
############# end

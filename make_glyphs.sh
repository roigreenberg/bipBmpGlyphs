IN='א ב ג ד ה ו ז ח ט י ך כ ל ם מ ן נ ס ע ף פ ץ צ ק ר ש ת װ ױ ײ' 
fontsize=18 
maxWidth=16
maxHeight=16
outFormat=png
font=/Users/alexeyabdusamatov/Desktop/wf_bin/double_time/ArialHebrew-Bold-02.ttf
arrIN=(${IN})
for symbol in $IN;do
    # echo $symbol
    hex=$(echo -n $symbol | od -tx1 -An| awk '{ print toupper($1$2) }')
    echo $symbol $hex
    echo -n $symbol | convert -background black -fill white -pointsize $fontsize -gravity center +antialias -font $font label:@- "$hex"_00.$outFormat
    width=$(convert "$hex"_00.$outFormat -ping -format '%w' info:)
    let "width--"
    widthHex=$(echo "obase=16; $width" | bc)
    # echo $width $widthHex
    mv "$hex"_00.$outFormat "$hex"_"$widthHex"0.$outFormat
done
#!/bin/bash

s=$1
/bin/bash ./make_glyphs.sh $s
cp -r ./$s/* ./extracts/Mili_chaohu_uni.ft_extract/
python3 font_parser_BIP.py ./extracts/Mili_chaohu_uni.ft_extract new

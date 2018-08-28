# -*- coding: utf-8 -*-
"""
Created on Thu Jan 25 11:28:47 2018

@author: 010IvanovVI

Script origin: http://myamazfit.ru/threads/parser-shriftov-amazfit-bip.96/
"""

import os
import sys
import json
import shutil
from PIL import Image


def get_unicode_table():
    unicode = dict.fromkeys(range(0,0x80), 'Основная латиница')
    unicode.update(dict.fromkeys(range(0x80,0x100), 'Дополнение к латинице 1'))
    unicode.update(dict.fromkeys(range(0x100,0x180), 'Расширенная латиница А'))
    unicode.update(dict.fromkeys(range(0x180,0x250), 'Расширенная латиница Б'))
    unicode.update(dict.fromkeys(range(0x250,0x2B0), 'Расширения МФА'))
    unicode.update(dict.fromkeys(range(0x2B0,0x300), 'Модификаторы букв'))
    unicode.update(dict.fromkeys(range(0x300,0x370), 'Комбинируемые диакритические знаки'))
    unicode.update(dict.fromkeys(range(0x370,0x400), 'Греческое и коптское письмо'))
    unicode.update(dict.fromkeys(range(0x400,0x500), 'Кириллица'))
    unicode.update(dict.fromkeys(range(0x500,0x530), 'Дополнение к кириллице'))
    unicode.update(dict.fromkeys(range(0x530,0x590), 'Армянское письмо'))
    unicode.update(dict.fromkeys(range(0x590,0x600), 'Иврит'))
    unicode.update(dict.fromkeys(range(0x600,0x700), 'Арабское письмо'))
    unicode.update(dict.fromkeys(range(0x700,0x750), 'Сирийское письмо'))
    unicode.update(dict.fromkeys(range(0x750,0x780), 'Дополнение к арабскому письму'))
    unicode.update(dict.fromkeys(range(0x780,0x7C0), 'Тана'))
    unicode.update(dict.fromkeys(range(0x7C0,0x800), 'Нко'))
    unicode.update(dict.fromkeys(range(0x800,0x840), 'Самаритянское письмо'))
    unicode.update(dict.fromkeys(range(0x840,0x860), 'Мандейское письмо'))
    unicode.update(dict.fromkeys(range(0x860,0x870), 'Дополнение к сирийскому письму'))
    unicode.update(dict.fromkeys(range(0x8A0,0x900), 'Расширенное арабское письмо А'))
    unicode.update(dict.fromkeys(range(0x900,0x980), 'Деванагари'))
    unicode.update(dict.fromkeys(range(0x980,0xA00), 'Бенгальское письмо'))
    unicode.update(dict.fromkeys(range(0xA00,0xA80), 'Гурмукхи'))
    unicode.update(dict.fromkeys(range(0xA80,0xB00), 'Гуджарати'))
    unicode.update(dict.fromkeys(range(0xB00,0xB80), 'Ория'))
    unicode.update(dict.fromkeys(range(0xB80,0xC00), 'Тамильское письмо'))
    unicode.update(dict.fromkeys(range(0xC00,0xC80), 'Телугу'))
    unicode.update(dict.fromkeys(range(0xC80,0xD00), 'Каннада'))
    unicode.update(dict.fromkeys(range(0xD00,0xD80), 'Малаялам'))
    unicode.update(dict.fromkeys(range(0xD80,0xE00), 'Сингальское письмо'))
    unicode.update(dict.fromkeys(range(0xE00,0xE80), 'Тайское письмо'))
    unicode.update(dict.fromkeys(range(0xE80,0xF00), 'Лаосское письмо'))
    unicode.update(dict.fromkeys(range(0xF00,0x1000), 'Тибетское письмо'))
    unicode.update(dict.fromkeys(range(0x1000,0x10A0), 'Бирманское письмо'))
    unicode.update(dict.fromkeys(range(0x10A0,0x1100), 'Грузинское письмо'))
    unicode.update(dict.fromkeys(range(0x1100,0x1200), 'Элементы хангыля'))
    unicode.update(dict.fromkeys(range(0x1200,0x1380), 'Эфиопское письмо'))
    unicode.update(dict.fromkeys(range(0x1380,0x13A0), 'Дополнение к эфиопскому письму'))
    unicode.update(dict.fromkeys(range(0x13A0,0x1400), 'Чероки'))
    unicode.update(dict.fromkeys(range(0x1400,0x1680), 'Канадское слоговое письмо'))
    unicode.update(dict.fromkeys(range(0x1680,0x16A0), 'Огамическое письмо'))
    unicode.update(dict.fromkeys(range(0x16A0,0x1700), 'Руны'))
    unicode.update(dict.fromkeys(range(0x1700,0x1720), 'Байбайин'))
    unicode.update(dict.fromkeys(range(0x1720,0x1740), 'Хануноо'))
    unicode.update(dict.fromkeys(range(0x1740,0x1760), 'Бухид'))
    unicode.update(dict.fromkeys(range(0x1760,0x1780), 'Тагбанва'))
    unicode.update(dict.fromkeys(range(0x1780,0x1800), 'Кхмерское письмо'))
    unicode.update(dict.fromkeys(range(0x1800,0x18B0), 'Старомонгольское письмо'))
    unicode.update(dict.fromkeys(range(0x18B0,0x1900), 'Расширенное канадское слоговое письмо'))
    unicode.update(dict.fromkeys(range(0x1900,0x1950), 'Лимбу'))
    unicode.update(dict.fromkeys(range(0x1950,0x1980), 'Лы'))
    unicode.update(dict.fromkeys(range(0x1980,0x19E0), 'Ныа'))
    unicode.update(dict.fromkeys(range(0x19E0,0x1A00), 'Кхмерские символы'))
    unicode.update(dict.fromkeys(range(0x1A00,0x1A20), 'Лонтара'))
    unicode.update(dict.fromkeys(range(0x1A20,0x1AB0), 'Ланна'))
    unicode.update(dict.fromkeys(range(0x1AB0,0x1B00), 'Расширенные комбинируемые диакритические знаки'))
    unicode.update(dict.fromkeys(range(0x1B00,0x1B80), 'Балийское письмо'))
    unicode.update(dict.fromkeys(range(0x1B80,0x1BC0), 'Сунданское письмо'))
    unicode.update(dict.fromkeys(range(0x1BC0,0x1C00), 'Батакское письмо'))
    unicode.update(dict.fromkeys(range(0x1C00,0x1C50), 'Лепча'))
    unicode.update(dict.fromkeys(range(0x1C50,0x1C80), 'Ол-чики'))
    unicode.update(dict.fromkeys(range(0x1C80,0x1CC0), 'Расширенная кирилица С'))
    unicode.update(dict.fromkeys(range(0x1CC0,0x1CD0), 'Дополнение к сунданскому письму'))
    unicode.update(dict.fromkeys(range(0x1CD0,0x1D00), 'Расширения Веды'))
    unicode.update(dict.fromkeys(range(0x1D00,0x1D80), 'Фонетические расширения'))
    unicode.update(dict.fromkeys(range(0x1D80,0x1DC0), 'Дополнение к фонетическим расширениям'))
    unicode.update(dict.fromkeys(range(0x1DC0,0x1E00), 'Дополнение к комбинируемым диакритическим знакам'))
    unicode.update(dict.fromkeys(range(0x1E00,0x1F00), 'Дополнение к расширенной латинице'))
    unicode.update(dict.fromkeys(range(0x1F00,0x2000), 'Расширенное греческое письмо'))
    unicode.update(dict.fromkeys(range(0x2000,0x2070), 'Основная пунктуация'))
    unicode.update(dict.fromkeys(range(0x2070,0x20A0), 'Надстрочные и подстрочные знаки'))
    unicode.update(dict.fromkeys(range(0x20A0,0x20D0), 'Знаки валют'))
    unicode.update(dict.fromkeys(range(0x20D0,0x2100), 'Комбинируемые диакритические знаки для символов'))
    unicode.update(dict.fromkeys(range(0x2100,0x2150), 'Буквоподобные символы'))
    unicode.update(dict.fromkeys(range(0x2150,0x2190), 'Числовые формы'))
    unicode.update(dict.fromkeys(range(0x2190,0x2200), 'Стрелки'))
    unicode.update(dict.fromkeys(range(0x2200,0x2300), 'Математические операторы'))
    unicode.update(dict.fromkeys(range(0x2300,0x2400), 'Разные технические знаки'))
    unicode.update(dict.fromkeys(range(0x2400,0x2440), 'Пиктограммы управляющих символов'))
    unicode.update(dict.fromkeys(range(0x2440,0x2460), 'Оптическое распознавание символов'))
    unicode.update(dict.fromkeys(range(0x2460,0x2500), 'Обрамленные буквы и цифры'))
    unicode.update(dict.fromkeys(range(0x2500,0x2580), 'Псевдографика'))
    unicode.update(dict.fromkeys(range(0x2580,0x25A0), 'Блочные элементы'))
    unicode.update(dict.fromkeys(range(0x25A0,0x2600), 'Геометрические фигуры'))
    unicode.update(dict.fromkeys(range(0x2600,0x2700), 'Разные символы'))
    unicode.update(dict.fromkeys(range(0x2700,0x27C0), 'Dingbats'))
    unicode.update(dict.fromkeys(range(0x27C0,0x27F0), 'Разные математические символы А'))
    unicode.update(dict.fromkeys(range(0x27F0,0x2800), 'Дополнение к стрелкам А'))
    unicode.update(dict.fromkeys(range(0x2800,0x2900), 'Шрифт Брайля'))
    unicode.update(dict.fromkeys(range(0x2900,0x2980), 'Дополнение к стрелкам Б'))
    unicode.update(dict.fromkeys(range(0x2980,0x2A00), 'Разные математические символы Б'))
    unicode.update(dict.fromkeys(range(0x2A00,0x2B00), 'Дополнение к математическим операторам'))
    unicode.update(dict.fromkeys(range(0x2B00,0x2C00), 'Разные символы и стрелки'))
    unicode.update(dict.fromkeys(range(0x2C00,0x2C60), 'Глаголица'))
    unicode.update(dict.fromkeys(range(0x2C60,0x2C80), 'Расширенная латиница В'))
    unicode.update(dict.fromkeys(range(0x2C80,0x2D00), 'Коптское письмо'))
    unicode.update(dict.fromkeys(range(0x2D00,0x2D30), 'Дополнение к грузинскому письму'))
    unicode.update(dict.fromkeys(range(0x2D30,0x2D80), 'Древнеливийское письмо'))
    unicode.update(dict.fromkeys(range(0x2D80,0x2DE0), 'Расширенное эфиопское письмо'))
    unicode.update(dict.fromkeys(range(0x2DE0,0x2E00), 'Расширенная кирилица А'))
    unicode.update(dict.fromkeys(range(0x2E00,0x2E80), 'Дополнение к пунктуации'))
    unicode.update(dict.fromkeys(range(0x2E80,0x2F00), 'Дополнение к ключам ККЯ'))
    unicode.update(dict.fromkeys(range(0x2F00,0x2FE0), 'Ключи Канси'))
    unicode.update(dict.fromkeys(range(0x2FF0,0x3000), 'Идеографические пояснительные символы'))
    unicode.update(dict.fromkeys(range(0x3000,0x3040), 'Символы и пунктуация ККЯ'))
    unicode.update(dict.fromkeys(range(0x3040,0x30A0), 'Хирагана'))
    unicode.update(dict.fromkeys(range(0x30A0,0x3100), 'Катакана'))
    unicode.update(dict.fromkeys(range(0x3100,0x3130), 'Чжуинь фухао'))
    unicode.update(dict.fromkeys(range(0x3130,0x3190), 'Совместимые элементы хангыля'))
    unicode.update(dict.fromkeys(range(0x3190,0x31A0), 'Камбун'))
    unicode.update(dict.fromkeys(range(0x31A0,0x31C0), 'Расширенное чжуинь фухао'))
    unicode.update(dict.fromkeys(range(0x31C0,0x31F0), 'Черты ККЯ'))
    unicode.update(dict.fromkeys(range(0x31F0,0x3200), 'Фонетические расширения катаканы'))
    unicode.update(dict.fromkeys(range(0x3200,0x3300), 'Обрамленные буквы и месяцы ККЯ'))
    unicode.update(dict.fromkeys(range(0x3300,0x3400), 'Совместимые элементы ККЯ'))
    unicode.update(dict.fromkeys(range(0x3400,0x4DC0), 'Унифицированные идеограммы ККЯ - Расширение А'))
    unicode.update(dict.fromkeys(range(0x4DC0,0x4E00), 'Гексаграммы Книги Перемен'))
    unicode.update(dict.fromkeys(range(0x4E00,0xA000), 'Унифицированные идеограммы ККЯ'))
    unicode.update(dict.fromkeys(range(0xA000,0xA490), 'Слоговое письмо и'))
    unicode.update(dict.fromkeys(range(0xA490,0xA4D0), 'Ключи письма и'))
    unicode.update(dict.fromkeys(range(0xA4D0,0xA500), 'Лису'))
    unicode.update(dict.fromkeys(range(0xA500,0xA640), 'Ваи'))
    unicode.update(dict.fromkeys(range(0xA640,0xA6A0), 'Расширенная кириллица Б'))
    unicode.update(dict.fromkeys(range(0xA6A0,0xA700), 'Бамум'))
    unicode.update(dict.fromkeys(range(0xA700,0xA720), 'Символы изменения тона'))
    unicode.update(dict.fromkeys(range(0xA720,0xA800), 'Расширенная латиница Г'))
    unicode.update(dict.fromkeys(range(0xA800,0xA830), 'Силхетское нагари'))
    unicode.update(dict.fromkeys(range(0xA830,0xA840), 'Общеиндийские числовые формы'))
    unicode.update(dict.fromkeys(range(0xA840,0xA880), 'Монгольское квадратное письмо'))
    unicode.update(dict.fromkeys(range(0xA880,0xA8E0), 'Саураштра'))
    unicode.update(dict.fromkeys(range(0xA8E0,0xA900), 'Расширенное деванагари'))
    unicode.update(dict.fromkeys(range(0xA900,0xA930), 'Кая-ли'))
    unicode.update(dict.fromkeys(range(0xA930,0xA960), 'Реджанг'))
    unicode.update(dict.fromkeys(range(0xA960,0xA980), 'Расширенные элементы хангыля А'))
    unicode.update(dict.fromkeys(range(0xA980,0xA9E0), 'Яванское письмо'))
    unicode.update(dict.fromkeys(range(0xA9E0,0xAA00), 'Расширенное бирманское письмо Б'))
    unicode.update(dict.fromkeys(range(0xAA00,0xAA60), 'Чамское письмо'))
    unicode.update(dict.fromkeys(range(0xAA60,0xAA80), 'Расширенное бирманское письмо А'))
    unicode.update(dict.fromkeys(range(0xAA80,0xAAE0), 'Тай-вьет'))
    unicode.update(dict.fromkeys(range(0xAAE0,0xAB00), 'Расширения манипури'))
    unicode.update(dict.fromkeys(range(0xAB00,0xAB30), 'Расширенное эфиопское письмо А'))
    unicode.update(dict.fromkeys(range(0xAB30,0xAB70), 'Расширенная латиница Д'))
    unicode.update(dict.fromkeys(range(0xAB70,0xABC0), 'Дополнение к чероки'))
    unicode.update(dict.fromkeys(range(0xABC0,0xAC00), 'Манипури'))
    unicode.update(dict.fromkeys(range(0xAC00,0xD7B0), 'Слоговое письмо хангыля'))
    unicode.update(dict.fromkeys(range(0xD7B0,0xD7C0), 'Расширенные элементы хангыля Б'))
    unicode.update(dict.fromkeys(range(0xD800,0xDB80), 'Верхняя часть суррогатных пар'))
    unicode.update(dict.fromkeys(range(0xDC00,0xE000), 'Нижняя часть суррогатных пар'))
    unicode.update(dict.fromkeys(range(0xE000,0xF900), 'Область для частного использования'))
    unicode.update(dict.fromkeys(range(0xF900,0xFB00), 'Совместимые идеограммы ККЯ'))
    unicode.update(dict.fromkeys(range(0xFB00,0xFB50), 'Алфавитные формы представления'))
    unicode.update(dict.fromkeys(range(0xFB50,0xFE00), 'Арабские формы представления А'))
    unicode.update(dict.fromkeys(range(0xFE00,0xFE10), 'Вариантные селекторы'))
    unicode.update(dict.fromkeys(range(0xFE10,0xFE20), 'Веритикальные формы'))
    unicode.update(dict.fromkeys(range(0xFE20,0xFE30), 'Комбинируемые полузнаки'))
    unicode.update(dict.fromkeys(range(0xFE30,0xFE50), 'Совместимые формы ККЯ'))
    unicode.update(dict.fromkeys(range(0xFE50,0xFE70), 'Малые вариантные формы'))
    unicode.update(dict.fromkeys(range(0xFE70,0xFF00), 'Арабские формы представления Б'))
    unicode.update(dict.fromkeys(range(0xFF00,0xFFF0), 'Полуширинные и полноширинные формы'))
    unicode.update(dict.fromkeys(range(0xFFF0,0x10000), 'Специальные символы'))
    return unicode


def extract_font(filepath):
    with open(filepath, 'rb') as font_file:
        font_binary_data = font_file.read()
        font_path = '{}_extract'.format(filepath)
        if os.path.exists(font_path):
            shutil.rmtree(font_path)
        os.mkdir(font_path)
        unicode_base = get_unicode_table()
        font_info = dict.fromkeys(['header', 'version'])
        font_info['header'] = list(font_binary_data[0:0x20])
        font_info['version'] = font_binary_data[4]
        with open('{}/font_info.json'.format(font_path), 'w') as infofile:
            json.dump(font_info, infofile, sort_keys=True, ensure_ascii=False, indent=4)
        letter_blocks = int.from_bytes(font_binary_data[0x20:0x22], byteorder='little')
        for block in range(0,letter_blocks*6,6):
            letter_code_start = int.from_bytes(font_binary_data[0x22+block:0x24+block], byteorder='little')
            letter_code_stop = int.from_bytes(font_binary_data[0x24+block:0x26+block], byteorder='little')
            letters_offset = int.from_bytes(font_binary_data[0x26+block:0x28+block], byteorder='little')
            hash_len=1 if font_info['version']==8 else 2
            letters_offset = 6*letter_blocks + 0x22 + (34-hash_len)*letters_offset
            while True:
                letter_data = font_binary_data[letters_offset:letters_offset+2*(17-hash_len)]
                letter_checksum = hex(int.from_bytes(font_binary_data[letters_offset+2*(17-hash_len):letters_offset+34-hash_len], byteorder='little'))[2:].rjust(2*hash_len,'0').upper()
                letter_name = hex(letter_code_start)[2:].rjust(4,'0').upper() + '_' + letter_checksum
                img = Image.frombuffer('1',(16,17-hash_len,),letter_data, 'raw', '1')
                letter_path = '{}/{}'.format(font_path,unicode_base[letter_code_start])
                if not os.path.exists(letter_path):
                    os.mkdir(letter_path)
                img.save('{}/{}.bmp'.format(letter_path,letter_name), 'BMP')
                letter_code_start += 1
                letters_offset = letters_offset + 34 - hash_len
                if letter_code_start == letter_code_stop+1:
                    break
            
        
def build_font(filepath, name_addition):
    with open('{}/font_info.json'.format(filepath),'r') as info_file:
        font_info = json.load(info_file)
        print(font_info)
        with open('new_{}_{}'.format(filepath[filepath.rindex('/') + 1 if filepath.find('/') > 0 else 0:-8], name_addition), 'wb') as font:
            print(font)
            font.write(bytes(font_info['header']))
            letter_paths = os.listdir(filepath)
            letter_paths.remove('font_info.json')
            new_font = {}
            for letter_path in letter_paths:
                letter_full_path = '{}/{}'.format(filepath,letter_path)
                for letter in os.listdir(letter_full_path):
                    bmp = Image.open(letter_full_path+'/'+letter)
                    font_array = list(bmp.tobytes())
                    if font_info['version']==8:
                        font_array.append(int(letter[5:7],16))
                    else:
                        font_array.extend([0,129])
                    new_font[int(letter[:4],16)] = font_array
                    bmp.close() 
            letters = list(new_font.keys())
            letters.sort()
            blocks_data = bytearray()
            raw_data = bytearray()
            blocks_count = 1
            letter_start = letters[0]
            letter_offset = 0
            for letter_num, letter in enumerate(letters,1):
                raw_data.extend(bytes(new_font[letter]))
                if letter_num != len(letters):
                    if letters[letter_num]-letter > 1:
                        blocks_data.extend(letter_start.to_bytes(2, byteorder='little'))
                        blocks_data.extend(letter.to_bytes(2, byteorder='little'))
                        blocks_data.extend(letter_offset.to_bytes(2, byteorder='little'))
                        letter_start = letters[letter_num]
                        letter_offset = letter_num
                        blocks_count += 1
            blocks_data.extend(letter_start.to_bytes(2, byteorder='little'))
            blocks_data.extend(letters[-1].to_bytes(2, byteorder='little'))
            blocks_data.extend(letter_offset.to_bytes(2, byteorder='little'))
            font.write(blocks_count.to_bytes(2, byteorder='little'))
            font.write(blocks_data)
            font.write(raw_data)


if __name__ == '__main__':
    if len(sys.argv) > 1:
        if os.path.exists(sys.argv[1]):
            if os.path.isfile(sys.argv[1]):
                extract_font(sys.argv[1])
            else:
                print("build")
                name_addition = ""
                if len(sys.argv) > 2:
                    name_addition = sys.argv[2]
                build_font(sys.argv[1], name_addition)
        else:
            print('Файл/папка не найдена!')
    else:
        print('Не указан файл/папка для обработки!')

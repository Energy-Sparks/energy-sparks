module I18n
  module Backend
    module Custom
      MIRRORED_CHARACTERS = {
        " " => " ",
        "a" => "ɐ",
        "b" => "q",
        "c" => "ɔ",
        "d" => "p",
        "e" => "ǝ",
        "f" => "ɟ",
        "g" => "ƃ",
        "h" => "ɥ",
        "i" => "ı",
        "j" => "ɾ",
        "k" => "ʞ",
        "l" => "l",
        "m" => "ɯ",
        "n" => "u",
        "o" => "o",
        "p" => "d",
        "q" => "b",
        "r" => "ɹ",
        "s" => "s",
        "t" => "ʇ",
        "u" => "n",
        "v" => "ʌ",
        "w" => "ʍ",
        "x" => "x",
        "y" => "ʎ",
        "z" => "z",
        "A" => "∀",
        "B" => "q",
        "C" => "Ɔ",
        "D" => "p",
        "E" => "Ǝ",
        "F" => "Ⅎ",
        "G" => "פ",
        "H" => "H",
        "I" => "I",
        "J" => "ſ",
        "K" => "ʞ",
        "L" => "˥",
        "M" => "W",
        "N" => "N",
        "O" => "O",
        "P" => "Ԁ",
        "Q" => "Q",
        "R" => "ɹ",
        "S" => "S",
        "T" => "┴",
        "U" => "∩",
        "V" => "Λ",
        "W" => "M",
        "X" => "X",
        "Y" => "⅄",
        "Z" => "Z",
        "," => "'",
        "!" => "¡",
        "?" => "¿",
        "(" => ")",
        ")" => "(",
        "[" => "]",
        "]" => "[",
        "/" => "\\",
        "." => "˙",
        '"' => ",,",
        "'" => ","
      }.freeze

      def translate(locale, key, options = EMPTY_HASH)
        if locale.to_s == 'mirror' && key
          entry = lookup('en', key, options[:scope], options)
          entry = pluralize('en', entry, options[:count]) if options[:count]

          return mirrored_text_for(entry) unless entry.nil?
        end
        super
      end

      def mirrored_text_for(entry)
        entry.split(//).reverse.map do |character|
          MIRRORED_CHARACTERS[character] || character
        end.join('')
      end
    end
  end
end

Time::DATE_FORMATS[:es_short] = lambda do |date|
        I18n.l(date, format: '%d %b %Y')
end
Time::DATE_FORMATS[:es_compact] = lambda do |date|
        I18n.l(date, format: '%d/%m/%Y %H:%M')
end
Time::DATE_FORMATS[:es_full] = lambda do |date|
        I18n.l(date, format: "%a #{date.day.ordinalize} %b %Y")
end
Date::DATE_FORMATS[:es_short] = lambda do |date|
        I18n.l(date, format: '%d %b %Y')
end
Date::DATE_FORMATS[:es_compact] = '%d/%m/%Y'
Date::DATE_FORMATS[:es_full] = lambda do |date|
        I18n.l(date, format: "%a #{date.day.ordinalize} %b %Y")
end

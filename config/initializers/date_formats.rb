Time::DATE_FORMATS[:es_short]   = ->(date_time) { I18n.l(date_time, format: '%d %b %Y') }
Time::DATE_FORMATS[:es_compact] = ->(date_time) { I18n.l(date_time, format: '%d/%m/%Y %H:%M') }
Time::DATE_FORMATS[:es_full]    = ->(date_time) { I18n.l(date_time, format: "%a #{date_time.day.ordinalize} %b %Y") }
Date::DATE_FORMATS[:es_short]   = ->(date) { I18n.l(date, format: '%d %b %Y') }
Date::DATE_FORMATS[:es_compact] = ->(date) { I18n.l(date, format: '%d/%m/%Y') }
Date::DATE_FORMATS[:es_full]    = ->(date) { I18n.l(date, format: "%a #{date.day.ordinalize} %b %Y") }

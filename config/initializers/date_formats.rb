Time::DATE_FORMATS[:es_short]   = lambda { |date_time| I18n.l(date_time, format: '%d %b %Y') }
Time::DATE_FORMATS[:es_compact] = lambda { |date_time| I18n.l(date_time, format: '%d/%m/%Y %H:%M') }
Time::DATE_FORMATS[:es_full]    = lambda { |date_time| I18n.l(date_time, format: "%a #{date_time.day.ordinalize} %b %Y") }
Date::DATE_FORMATS[:es_short]   = lambda { |date| I18n.l(date, format: '%d %b %Y') }
Date::DATE_FORMATS[:es_compact] = lambda { |date| I18n.l(date, format: '%d/%m/%Y') }
Date::DATE_FORMATS[:es_full]    = lambda { |date| I18n.l(date, format: "%a #{date.day.ordinalize} %b %Y") }
Date::DATE_FORMATS[:es_long]    = lambda { |date| I18n.l(date, format: "#{date.day.ordinalize} %B %Y") }
Date::DATE_FORMATS[:es_month]   = lambda { |date| I18n.l(date, format: '%B %Y') }

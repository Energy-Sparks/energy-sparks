Date::DATE_FORMATS.merge!({ es_short: '%d %b %Y' })
Date::DATE_FORMATS.merge!({ es_full: lambda { |date| date.strftime("%a #{date.day.ordinalize} %b %Y")}})

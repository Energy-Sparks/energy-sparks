Time::DATE_FORMATS.merge!({ es_short: '%d %b %Y' })
Time::DATE_FORMATS.merge!(
  {
    es_full:
      lambda do |date|
        I18n.l(date, format: "%a #{date.day.ordinalize} %b %Y")
      end
  }
)
Date::DATE_FORMATS.merge!({ es_short: '%d %b %Y' })
Date::DATE_FORMATS.merge!({ es_compact: '%d/%m/%Y' })
Date::DATE_FORMATS.merge!(
  {
    es_full:
      lambda do |date|
        I18n.l(date, format: "%a #{date.day.ordinalize} %b %Y")
      end
  }
)

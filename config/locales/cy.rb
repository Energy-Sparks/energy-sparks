# Ordinal abreviations have been adapted from
# https://www.bangor.ac.uk/cymorthcymraeg/dyddiadau.php.en
# https://omniglot.com/language/numbers/welsh.htm
# See also: https://github.com/rails/rails/blob/main/activesupport/lib/active_support/locale/en.rb
#
# Number | Ordinals                 | Abbreviation
# -------+--------------------------+-------------
# 1      | cyntaf                   | 1af
# 2      | ail                      | 2ail
# 3      | trydydd                  | 3ydd   trydedd(Fem)
# 4      | pedwerydd                | 4ydd   pedwaredd(Fem)
# 5      | pumed                    | 5ed
# 6      | chweched                 | 6ed
# 7      | seithfed                 | 7fed
# 8      | wythfed                  | 8fed
# 9      | nawfed                   | 9fed
# 10     | degfed                   | 10fed
# 11     | unfed ar ddeg            | 11eg
# 12     | deuddegfed               | 12fed
# 13     | trydydd ar ddeg          | 13eg
# 14     | pedwerydd ar ddeg        | 14eg
# 15     | pymthegfed               | 15fed
# 16     | unfed ar bymtheg         | 16eg
# 17     | ail ar bymtheg           | 17eg
# 18     | deunawfed                | 18fed
# 19     | pedwerydd ar bymtheg     | 19eg
# 20     | ugeinfed                 | 20fed
# 21     | unfed ar hugain          | 21ain
# 22     | ail ar hugain            | 22ain
# 23     | trydydd ar hugain        | 23ain
# 24     | pedwerydd ar hugain      | 24ain
# 25     | pumed ar hugain          | 25ain
# 26     | chweched ar hugain       | 26ain
# 27     | seithfed ar hugain       | 27ain
# 28     | wythfed ar hugain        | 28ain
# 29     | nawfed ar hugain         | 29ain
# 30     | degfed ar hugain         | 30ain
# 31     | unfed ar ddeg ar hugain  | 31ain
{
  cy: {
    number: {
      nth: {
        ordinals: lambda do |_key, options|
          number = options[:number]
          case number
          when 1 then 'af'
          when 2 then 'ail'
          when 3, 4 then 'ydd'
          when 5, 6 then 'ed'
          when 7, 8, 9, 10, 12, 15, 18, 20, 40, 50, 60, 70, 80, 90, 100 then 'fed'
          when 11, 13, 14, 16, 17, 19 then 'eg'
          when 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39 then 'ain'
          else
            num_modulo = number.to_i.abs % 100
            num_modulo %= 10 if num_modulo > 13
            case num_modulo
            when 1 then 'af'
            when 2 then 'ail'
            when 3, 4 then 'ydd'
            when 5, 6 then 'ed'
            when 7, 8, 9, 10, 12, 15, 18, 20, 40, 50, 60, 70, 80, 90, 100 then 'fed'
            when 11, 13, 14, 16, 17, 19 then 'eg'
            when 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39 then 'ain'
            end
          end
        end,

        ordinalized: lambda do |_key, options|
          number = options[:number]
          "#{number}#{ActiveSupport::Inflector.ordinal(number)}"
        end
      }
    }
  }
}

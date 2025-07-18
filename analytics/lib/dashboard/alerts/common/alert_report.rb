# class containing descriptive results of alerts
# - type:     enumeration of type of analysis, tied in to a specific analysis class (see base class above)
# - summary:  a brief descriptive summary of the issue (text)
# - term:     :short, :medium, :long_term
# - help_url: an optional link to further information on interpreting the alert
# - detail:   an array of AlertDescriptionDetail - potential mixed media results e.g. text, then html, then a chart
# - rating:   on this metric out of 10
# - status:   :good, :ok, :poor (only expecting to report ':poor' alerts, the rest are for information)

#TODO: Remove?
#Only referenced from new_example_alert.rb which doesnt contain any real code
class AlertReport
  ALERT_HELP_URL = 'http://blog.energysparks.uk/alerts'.freeze
  MAX_RATING = 10.0
  attr_accessor :type, :summary, :term, :help_url, :detail, :rating, :status, :max_asofdate

  def initialize(type)
    @type = type
    @detail = []
  end

  def add_book_mark_to_base_url(bookmark)
    @help_url = ALERT_HELP_URL + '#' + bookmark
  end

  def add_detail(detail)
    @detail.push(detail)
  end

  def to_s
    out = sprintf("%-20s%s\n", 'Type:', @type)
    out += sprintf("%-20s%s\n", 'Summary:', @summary)
    out += sprintf("%-20s%s\n", 'Term:', @term)
    out += sprintf("%-20s%s\n", 'URL:', @help_url)
    out += sprintf("%-20s%s\n", 'Rating:', @rating.nil? ? 'unrated' : @rating.round(0))
    @detail.each do |info|
      out += sprintf("%-20s%s\n", 'Detail: type', info.type)
      out += sprintf("%-20s%s\n", '', info.content)
    end
    out += sprintf("%-20s%s\n", 'Status:', @status)
    out += "Max as of date: #{max_asofdate}"
    out
  end
end

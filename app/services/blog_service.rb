require 'net/http'

require 'uri'
require 'active_support/time'

class BlogService
  CACHE_EXPIRY_PERIOD = 1.hour
  CACHE_WARNING_PERIOD = 2.hours
  RETRY_PERIOD = 1.second

  attr_reader :key, :inline_fetch, :url, :retries

  def initialize(url: 'https://blog.energysparks.uk/feed/', inline_fetch: true, retries: 0)
    @url = url
    @key = "blog:#{url}"
    @inline_fetch = inline_fetch
    @retries = retries
  end

  def cached_feed
    Rails.cache.fetch(key)
  end

  def expired?
    cached_feed&.dig(:timestamp) && cached_feed[:timestamp] < CACHE_EXPIRY_PERIOD.ago
  end

  def fetch_feed?
    !cached_feed || expired?
  end

  def log_error?
    cached_feed&.dig(:timestamp) && (cached_feed[:timestamp] < CACHE_WARNING_PERIOD.ago)
  end

  def tries
    retries + 1
  end

  def items
    cache_feed! if inline_fetch

    cached_feed&.dig(:items)
  end

  # Can be run in cron to decouple from this tie-ing up the front page request
  def cache_feed!
    if fetch_feed?
      tries.times do |x|
        response = Net::HTTP.get_response(URI.parse(url))
        if response.is_a?(Net::HTTPSuccess)
          return Rails.cache.write(key, extract_items(response.body))
        elsif retries == x && log_error?
          Rollbar.error("Blog #{url} cache is over #{CACHE_WARNING_PERIOD.seconds.in_hours} out of date: #{response.code} #{response.message}")
        else
          sleep(RETRY_PERIOD)
        end
      end
    end
  end

  private

  def extract_items(body)
    feed = RSS::Parser.parse(body, false)
    { timestamp: Time.zone.now,
      items: feed.items.collect do |item|
        { title: item.title,
          image: item.enclosure&.url,
          description: item.description,
          link: item.link,
          date: item.pubDate,
          categories: item.categories.collect(&:content),
          author: item.dc_creator }
      end }
  end
end

require 'net/http'

require 'uri'
require 'active_support/time'

class BlogService
  CACHE_EXPIRY_PERIOD = 1.hour
  CACHE_ERROR_PERIOD = 2.hours
  RETRY_PERIOD = 1.second

  attr_reader :key, :url, :retries, :force_fetch

  def initialize(url: 'https://blog.energysparks.uk/feed/', retries: 0, force_fetch: false)
    @url = url
    @key = "blog:#{url}"
    @retries = retries
    @force_fetch = force_fetch
  end

  def cached_feed
    Rails.cache.fetch(key)
  end

  def cache_out_of_date?(period)
    !cached_feed || cached_feed&.dig(:timestamp) && cached_feed[:timestamp] < period.ago
  end

  def cache_expired?
    cache_out_of_date?(CACHE_EXPIRY_PERIOD)
  end

  def caching_on?
    !!Rails.application.config.action_controller.perform_caching
  end

  def fetch_feed?
    cache_expired? || force_fetch
  end

  def raise_error?
    caching_on? && cache_out_of_date?(CACHE_ERROR_PERIOD)
  end

  def tries
    retries + 1
  end

  def items
    if fetch_feed? && (feed = fetch_feed)
      Rails.cache.write(key, feed)
      return feed&.dig(:items)
    elsif raise_error?
      Rollbar.error("Blog cache for: #{url} is over #{CACHE_ERROR_PERIOD.seconds.in_hours} hours out of date")
    end
    cached_feed&.dig(:items)
  end

  # Can be run from cron if we don't want to tie up the front-page request
  def update_cache!
    Rails.cache.write(key, fetch_feed) if fetch_feed?
  end

  # Can be run in cron to decouple from this tie-ing up the front page request
  def fetch_feed
    tries.times do |x|
      Rails.logger.info "FETCHING #{url} (#{(x + 1).ordinalize} time): #{url}"
      response = Net::HTTP.get_response(URI.parse(url))
      if response.is_a?(Net::HTTPSuccess)
        return extract_feed(response.body)
      else
        Rails.logger.error("Unable to fetch #{url} after #{tries + 1} tries: #{response.code} #{response.message}")
        sleep(RETRY_PERIOD)
      end
    end
    false
  end

  private

  def clean(html)
    fragment = Nokogiri::HTML.fragment(html)
    # Remove all element nodes (and therefore their content)
    fragment.css('*').remove
    fragment.to_s.strip
  end

  def extract_feed(body)
    feed = RSS::Parser.parse(body, false)
    { timestamp: Time.zone.now,
      items: feed.items.collect do |item|
        { title: item.title,
          image: item.enclosure&.url,
          description: clean(item.description),
          link: item.link,
          date: item.pubDate.to_date.to_s,
          categories: item.categories.collect(&:content),
          author: item.dc_creator }
      end }
  end
end

require 'net/http'
require 'uri'

class BlogService
  RETRY_OPTIONS = {
    interval: 0.5,
    interval_randomness: 0.5,
    backoff_factor: 2
  }.freeze

  attr_reader :url, :retries, :key

  def initialize(url: 'https://blog.energysparks.uk/feed/', retries: 2)
    @url = url
    @key = "blog:#{url}"
    @retries = retries

    @connection = Faraday.new(url: url) do |f|
      f.request :retry, RETRY_OPTIONS.merge(max_option)
      f.response :logger if Rails.env.development?
    end
  end

  def cached_items
    Rails.cache.read(@key)
  end

  def items
    if Rails.env.development?
      return fetch_items
    else
      return cached_items || []
    end
  end

  # To be run from cron
  def cache_feed!
    if (items = fetch_items)
      Rails.cache.write(@key, items)
    end
  end

  private

  def fetch_items
    response = @connection.get
    if response.success?
      return extract_items(response.body)
    else
      Rollbar.error("Unable to fetch Blog url: #{url}. Status: #{response.status}, Body: #{response.body}")
    end
    false
  end

  def max_option
    retries ? { max: retries } : {}
  end

  def clean(html)
    fragment = Nokogiri::HTML.fragment(html)
    # Remove all element nodes (and therefore their content)
    fragment.css('*').remove
    fragment.to_s.strip
  end

  def extract_items(body)
    feed = RSS::Parser.parse(body, false)
    feed.items.collect do |item|
      { title: item.title,
        image: item.enclosure&.url,
        description: clean(item.description),
        link: item.link,
        date: item.pubDate.to_date.to_s,
        categories: item.categories.collect(&:content),
        author: item.dc_creator,
        author_link: "#{feed.channel.link}/author/#{item.dc_creator.parameterize}" }
    end
  end
end

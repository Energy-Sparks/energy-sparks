require 'net/http'
require 'uri'

class BlogService
  RETRY_OPTIONS = {
    interval: 0.5,
    interval_randomness: 0.5,
    backoff_factor: 2
  }.freeze

  IGNORE_TAG = 'Time sensitive'.freeze

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

  def items
    Rails.cache.read(@key) || []
  end

  # To be run from cron
  def update_cache!
    items = fetch_items
    if items&.any?
      Rails.cache.write(@key, items)
      Rails.logger.info "Blog cache updated: #{@key}"
    end
  end

  private

  def fetch_items
    response = @connection.get
    if response.success?
      extract_items(response.body)
    else
      Rollbar.error("Unable to fetch blog feed: #{url}. Status: #{response.status}, body: #{response.body}")
    end
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
    items = []
    if feed&.items
      items = feed.items.collect do |item|
        # ignore items with this tag
        next if item.categories.any? { |cat| cat.content.strip.downcase == IGNORE_TAG.downcase }

        { title: item.title,
          image: item.enclosure&.url,
          description: clean(item.description),
          link: item.link,
          date: item.pubDate.to_date.to_s,
          categories: item.categories.collect(&:content),
          author: item.dc_creator,
          author_link: "#{feed.channel.link}/author/#{item.dc_creator.parameterize}" }
      end.compact
    end
    Rollbar.error("No items extracted from blog feed: #{url}") if items.empty?
    items
  end
end

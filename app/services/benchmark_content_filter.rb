class BenchmarkContentFilter
  attr_accessor :title

  def initialize(content)
    @content = filter_content(content)
  end

  def intro
    @content[:intro]
  end

  def charts
    @content[:charts]
  end

  def tables
    @content[:tables]
  end

private

  def filter_content(content)
    group = {}
    key = :intro
    content.each do |fragment|
      if select_fragment?(fragment)
        @title ||= fragment[:content] if fragment[:type] == :title
        key = new_key(key, fragment)
        (group[key] ||= []) << fragment
      end
    end
    group
  end

  def new_key(key, fragment)
    if fragment[:type] == :chart
      :charts
    elsif fragment[:type] == :table_composite
      :tables
    else
      key
    end
  end

  def select_fragment?(fragment)
    return false unless fragment.present?
    [:title, :chart, :html, :table_composite].include?(fragment[:type]) && fragment[:content].present?
  end
end

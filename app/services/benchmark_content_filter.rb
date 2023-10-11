class BenchmarkContentFilter
  attr_accessor :title
  attr_reader :counts

  def initialize(content)
    @counts = count_content_types(content)
    benchmarks = group_content(content)
    @content = {}

    if benchmarks.count > 0
      extract_title(benchmarks[0])
      filter_content(benchmarks[0])
      extract_rest(benchmarks.drop(1))
    end
  end

  def intro
    @content[:intro] ||= []
  end

  def charts
    @content[:charts] ||= []
  end

  def tables
    @content[:tables] ||= []
  end

  def charts?(count: 1)
    @counts[:chart] && @counts[:chart] >= count
  end

  def tables?(count: 1)
    @counts[:table_composite] && @counts[:table_composite] >= count
  end

  def multi?
    charts?(count: 2) || tables?(count: 2)
  end

  private

  def extract_title(content)
    i = content.find_index { |fragment| fragment[:type] == :title && fragment[:content].present? }
    @title = content.delete_at(i)[:content] if i
  end

  def count_content_types(content)
    content.each_with_object({}) do |fragment, counts|
      counts[fragment[:type]] ||= 0
      counts[fragment[:type]] += 1
    end
  end

  def group_content(content)
    benchmarks = []
    i = -1
    content.each do |fragment|
      if select_fragment?(fragment)
        i += 1 if fragment[:type] == :title
        (benchmarks[i] ||= []) << fragment
      end
    end
    benchmarks
  end

  def filter_content(content)
    key = :intro
    content.each do |fragment|
      if select_fragment?(fragment)
        key = new_key(key, fragment)
        (@content[key] ||= []) << fragment
      end
    end
  end

  def new_key(key, fragment)
    key(fragment) || key
  end

  def key(fragment)
    if fragment[:type] == :chart
      :charts
    elsif fragment[:type] == :table_composite
      :tables
    end
  end

  def select_fragment?(fragment)
    return false if fragment.blank?

    %i[title chart html table_composite].include?(fragment[:type]) && fragment[:content].present?
  end

  def extract_rest(benchmarks)
    benchmarks.each do |benchmark|
      parse_benchmark(benchmark)
    end
  end

  def parse_benchmark(benchmark)
    chunk = []
    intro = []
    keep = ''
    benchmark.each do |fragment|
      key = key(fragment)
      keep = key if key

      if keep.blank?
        intro << fragment
      else
        chunk << fragment
      end

      next unless key

      @content[keep] ||= []
      @content[keep] += intro + chunk
      chunk = []
    end
    if chunk.any? && keep
      @content[keep] ||= []
      @content[keep] += chunk
    end
  end
end

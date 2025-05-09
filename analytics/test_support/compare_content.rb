class CompareContentResults
  attr_reader :control, :school_or_type
  def initialize(control, school_or_type, results_sub_directory_type:)
    @control = control # [ :summary, :quick_comparison, :report_differing_charts, :report_differences ]
    @school_or_type = school_or_type
    @identical_result_count = 0
    @differing_results = {} # [chart_name] => differences
    @missing = []
    @results_sub_directory_type = results_sub_directory_type
  end

  def save_and_compare_content(page, content, merge_page = false)
    comparison_content = load_comparison_content(page, merge_page)
    differences = compare_content(comparison_content, content, page)
    save_new_content(page, content, merge_page)
    differences
  end

  def compare_chart_list(chart_list)
    return if control.nil?
    chart_list.each do |name, content|
      save_and_compare_chart_data(name, content)
    end
    puts "Comparison: #{@identical_result_count} matching charts, advice; #{@differing_results.length} differ #{@missing.length} missing" if control_contains?(:summary)
  end

  private

  def comparison_directory
    TestDirectory.instance.base_comparison_directory(@results_sub_directory_type)
  end

  def output_directory
    TestDirectory.instance.results_comparison_directory(@results_sub_directory_type)
  end

  def control_hash_value(type)
    @control[:compare_results].map{ |val| val.is_a?(Hash) ? val.dig(type) : nil }.compact[0]
  end

  private def save_new_content(page, content, merge_page = false)
    if merge_page
      filename = File.join(output_directory, "#{school_or_type} #{page}.yaml".strip)
      save_yaml_file(filename, content)
    else
      split_content = split_content(content)
      split_content.each do |key, contents|
        filename = File.join(output_directory, "#{school_or_type} #{page} #{key}.yaml".strip)
        save_yaml_file(filename, contents)
      end
    end
  end

  private def load_comparison_content(page, merge_page)
    content = []
    if merge_page
      filenames = Dir.glob("#{school_or_type} #{page}.yaml".strip, base: comparison_directory)
      raise EnergySparksUnexpectedStateException, "Only expecting 1 filename , got #{filenames.length} #{filenames}" if filenames.length > 1
      return [] if filenames.length == 0
      full_filename = File.join(comparison_directory, filenames[0])
      content = load_yaml_file(full_filename)
    else
      filenames = Dir.glob("#{school_or_type} #{page}*.yaml".strip, base: comparison_directory)
      content = Array.new(filenames.length)
      filenames.each do |filename|
        index_string, key = filename.gsub("#{school_or_type} #{page} ".strip,'').gsub('.yaml', '').split(' ')
        full_filename = File.join(comparison_directory, filename)
        content[index_string.to_i] = { type: key.to_sym, content: load_yaml_file(full_filename) }
      end
    end
    content
  end

  def split_content(content)
    split_content = {}
    content.each_with_index do |content_component, n|
      split_content["#{n} #{content_component[:type]}"] = content_component[:content]
    end
    split_content
  end

  def save_yaml_file(yaml_filename, data)
    File.open(yaml_filename, 'w') { |f| f.write(YAML.dump(data)) }
  end

  def load_yaml_file(yaml_filename)
    YAML::load_file(yaml_filename)
  end

  def compare_content(comparison_content, new_content, page)
    differences = []
    if comparison_content.length == new_content.length
      comparison_content.each_with_index do |comparison_component, index|
        differences.push(compare_content_component(comparison_component, new_content[index], index))
      end
    else
      differences = new_content
      puts "Components differ: old: #{comparison_content.length} v. new: #{new_content.length} for #{page}"
    end
    differences.compact
  end

  def compare_content_component(comparison_component_orig, new_component_orig, index)
    comparison_component = strip_content_of_volatile_data(comparison_component_orig)
    new_component        = strip_content_of_volatile_data(new_component_orig)

    if comparison_component != new_component
      remove_content_classes(comparison_component)
      remove_content_classes(new_component)
      if comparison_component != new_component
        if @control[:compare_results].include?(:report_differences)
          tolerance = 0.000001
          h_diff = Hashdiff.diff(comparison_component, new_component, use_lcs: false, :numeric_tolerance => tolerance)
          if h_diff.empty?
            puts "Object comparison differences but Hashdiff doesnt (tolerance #{tolerance})"
          else
            puts "Differs: #{index}"
            puts "Difference:"
            puts h_diff
            puts 'Original:'
            puts comparison_component
            puts 'Versus:'
            puts new_component
          end
        end
        return new_component_orig
      end
    end
    nil
  end

  def remove_content_classes(data)
    remove_drilldown_content_classes(data)
    remove_content_class(data)
  end

  # the benchmark tables contain object references, which include
  # the dynamic addreess of the object, so are not comparable
  # e.g. :drilldown_content_class=>#<Class:0x000000000527cef0>
  def remove_drilldown_content_classes(data)
    return if !data.is_a?(Hash) || !data.key?(:type) || data[:type] != :table_composite
    data[:content][:rows].each do |row|
      row.each do |column|
        column.delete(:drilldown_content_class)
      end
    end
  end

  def remove_content_class(data)
    return if !data.is_a?(Hash) || !data.key?(:type) || data[:type] != :drilldown
    data[:content][:drilldown].delete(:content_class) unless data.dig(:content, :drilldown, :content_class).nil?
  end

  def save_and_compare_chart_data(chart_name, charts)
    if chart_name.is_a?(Hash)
      puts 'Unable to save and compare composite chart'
      return
    end

    save_chart(TestDirectory.instance.results_directory(@results_sub_directory_type), chart_name, charts)
    previous_chart = load_chart(TestDirectory.instance.base_comparison_directory(@results_sub_directory_type), chart_name)
    if previous_chart.nil?
      @missing.push(chart_name)
      return
    end
    compare_charts(chart_name, previous_chart, charts)
  end

  def strip_content_of_volatile_data(content)
    # puts "Removing volatile content"
    content = content.deep_dup
    if content[:content].is_a?(Hash)
      content[:content] = content[:content].except(:calculation_time)
      unless content[:content][:advice_header].nil?
        content[:content][:advice_header] = remove_volatile_html(content[:content][:advice_header])
      end
    elsif content[:content].is_a?(String)
      content[:content] = remove_volatile_html(content[:content])
    end
    content
  end

  def remove_volatile_html(html)
    [
      ['This saving is equivalent', '</button>'],
      ['sourcing its electricity from in the last 5 minutes:', 'The first column'],
      ['National Electricity Grid is currently', ' kg CO2/kWh.'],
      ['<th scope="col"> Percentage of Carbon </th>', '<td> coal </td>'], # not ideal as doesn't quite match end of table
      ['<th scope="col"> Percent of Energy </th>', '</tbody>'],
    ].each do |start_match, end_match|
      html = strip_volatile_content(html, start_match, end_match)
    end
    html
  end

  def strip_volatile_content(html, start_match, end_match)
    start_index = html.index(start_match)
    end_index = html.index(end_match)

    if !start_index.nil? && !end_index.nil?
      end_index = html.index(end_match) + end_match.length
      html = html[0...start_index] + html[end_index...html.length]
    elsif !start_index.nil? && !end_index.nil? && start_index >= end_index
      puts 'Start and index for remove_volatile_html in wrong order - consider longer match on text'
    end

    html
  end

  def compare_charts(chart_name, old_data, new_data)
    old_data = strip_chart_of_volatile_data(old_data)
    new_data = strip_chart_of_volatile_data(new_data)
    same = old_data == new_data
    if same
      @identical_result_count +=1
    else
      @differing_results[chart_name] = true # set for summary purposes
      puts "Chart results for #{chart_name} differ" if control_contains?(:quick_comparison)
      if control_contains?(:report_differences) # HashDiff is horribly slow, so only run if necessary
        h_diff = Hashdiff.diff(old_data, new_data, use_lcs: false, :numeric_tolerance => 0.000001) # use_lcs is O(N) otherwise and takes hours!!!!!
        @differing_results[chart_name] = h_diff
        puts "Chart results for #{chart_name} differ"
        puts h_diff if control_contains?(:quick_comparison)
      end
    end
  end

  def load_chart(path, chart_name)
    yaml_filename = yml_filepath(path, chart_name)
    return nil unless File.file?(yaml_filename)
    YAML::load_file(yaml_filename)
  end

  def save_chart(path, chart_name, data)
    yaml_filename = yml_filepath(path, chart_name)
    File.open(yaml_filename, 'w') { |f| f.write(YAML.dump(data)) }
  end

  def control_contains?(key)
    return true if control.include?(key)
    hash_controls.key?(key)
  end

  def hash_controls
    h = control.select { |entry| entry.is_a?(Hash) }.inject(:merge)
    h.nil? ? {} : h
  end

  def yml_filepath(path, chart_name)
    full_path ||= File.join(File.dirname(__FILE__), path)
    Dir.mkdir(full_path) unless File.exist?(full_path)
    extension = control_contains?(:name_extension) ? ('- ' + hash_controls[:name_extension].to_s) : ''
    yaml_filename = full_path + @school_name + '-' + chart_name.to_s + extension + '.yaml'
    yaml_filename.length > 259 ? shorten_filename(yaml_filename) : yaml_filename
  end
end

class CompareContent2 < CompareContentResults
  def initialize(school_name, control, results_sub_directory_type:)
    @school_name = school_name
    @control = control
    @results_sub_directory_type =  results_sub_directory_type
  end

  def save_and_compare(type, content)
    benchmark = load_yaml(yaml_filename(comparison_directory, type))
    save_yaml(yaml_filename(output_directory, type), content)

    non_volatile_benchmark = strip_volatile_data(benchmark)
    non_volatile_content   = strip_volatile_data(content)
    differs = non_volatile_benchmark != non_volatile_content
    report_difference(type, non_volatile_benchmark, non_volatile_content, differs) if differs || !@control[:compare_results][:report_if_differs]
  end

  private

  def strip_volatile_data(content)
    return nil if content.nil?

    s_c = content.deep_dup
    s_c.each do |component|
      component.delete(:calculation_time)
    end
    s_c
  end

  def yaml_filename(directory, type)
    directory + '/' + @school_name + ' ' + type + '.yaml'
  end

  def load_yaml(filename)
    YAML::load_file(filename) rescue nil
  end

  def save_yaml(filename, content)
    File.open(filename, 'w') { |f| f.write(YAML.dump(content)) }
  end

  def comparison_directory
    TestDirectory.instance.base_comparison_directory(@results_sub_directory_type)
  end

  def output_directory
    TestDirectory.instance.results_comparison_directory(@results_sub_directory_type)
  end

  def report_difference(type, benchmark, new_content, differs)
    if differs && benchmark.nil?
      puts "#{format_type(type)} benchmark content missing"
    elsif differs && new_content.nil?
      puts "#{format_type(type)} new content missing"
    elsif @control[:compare_results][:summary] == true
      puts "#{format_type(type)} differs"
    elsif %i[detail differences].include?(@control[:compare_results][:summary]) && differs
      detailed_differences(type, benchmark, new_content, @control[:compare_results][:h_diff] )
      print_raw_data(benchmark, new_content) if @control[:compare_results][:h_diff] == :detail
    end
  end

  def format_type(type)
    sprintf('%-60.60s', type)
  end

  def detailed_differences(type, benchmark, new_content, tolerance)
    tolerance ||= { use_lcs: false, :numeric_tolerance => 0.000001 }
    h_diff = Hashdiff.diff(benchmark, new_content, tolerance)
    puts "'Difference for #{type}:"
    puts h_diff
  end

  def print_raw_data(benchmark, new_content)
    puts 'Original:'
    puts benchmark
    puts 'Versus:'
    puts new_content
  end
end

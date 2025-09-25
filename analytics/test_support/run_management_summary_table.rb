class RunManagementSummaryTable < RunCharts
  attr_reader :html

  def initialize(school)
    super(school, results_sub_directory_type: self.class.test_type)
  end

  def run_management_table(control)
    results = calculate
    compare_results(control, results)
    @html = results[:html]
  end

  def self.test_type
    'ManagementSummaryTable'
  end

  def self.default_config
    self.superclass.default_config.merge({ management_summary_table: self.management_summary_table_config })
  end

  def self.management_summary_table_config
    {
      control: {
        combined_html_output_file: "Management Summary Table #{Date.today}",
        compare_results: [
          :summary,
          :report_differences
        ]
      }
    }
  end

  private

  def calculate
    content = ManagementSummaryTable.new(@school)
    puts 'Invalid content' unless content.valid_content?
    content.analyse(nil)
    puts 'Content failed' unless content.make_available_to_users?

    {
      front_end_template_tables:      ManagementSummaryTable.front_end_template_tables,
      front_end_template_table_data:  content.front_end_template_table_data,
      raw_variables_for_saving:       content.raw_variables_for_saving,
    }
  end

  def compare_results(control, results)
    results.each do |type, content|
      comparison = CompareContentResults.new(control, @school.name, results_sub_directory_type: self.class.test_type)
      comparison.save_and_compare_content(type.to_s, [{ type: type, content: content }])
    end
  end
end

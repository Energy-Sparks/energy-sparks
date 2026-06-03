class RunEquivalences < RunCharts
  def initialize(school)
    super(school, results_sub_directory_type: self.class.test_type)
  end

  def self.test_type
    'Equivalences'
  end

  def self.default_config
    self.superclass.default_config.merge({ equivalences: self.equivalence_default_config })
  end

  def self.equivalence_default_config
    {
      control: {
        periods: [
          {academicyear: 0},
          {academicyear: -1},
          {year: 0},
          {workweek: 0},
          {week: 0},
          {schoolweek: 0},
          {schoolweek: -1},
          {month: 0},
          {month: -1}
        ],
        compare_results: [ :report_differences ]
      }
    }
  end

  def run_equivalences(control)
    periods = control[:periods]
    fuel_types = @school.fuel_types(false, true)
    conversion = EnergyConversions.new(@school)
    list_of_conversions = EnergyConversions.front_end_conversion_list
    fuel_types.each do |fuel_type|
      equivalences = {}
      periods.each do |period|
        list_of_conversions.each_key do |equivalence_type|
          name = equivalence_description(fuel_type, period, equivalence_type)
          equivalence = calculate_equivalence(conversion, equivalence_type, period, fuel_type)
          equivalences[name.to_sym] = equivalence
        end
      end
      comparison = CompareContentResults.new(control, @school.name, results_sub_directory_type: self.class.test_type)
      comparison.save_and_compare_content(fuel_type.to_s, [{ type: :eq, content: equivalences }])
    end
  end

  private

  def calculate_equivalence(conversion, type, period, fuel_type)
    equivalence = nil
    begin
      equivalence = conversion.front_end_convert(type, period, fuel_type)
    rescue EnergySparksNotEnoughDataException => e
      equivalence = 'Not enough data'
    end
    equivalence
  end

  def equivalence_description(fuel_type, period, equivalence_type)
    "#{fuel_type}_#{period.keys[0]}_#{period.values[0]}_#{equivalence_type}"
  end
end

require_relative './synthetic_school.rb'

class BenchmarkSchool < SyntheticSchool
  def initialize(meter_collection, benchmark_type: :benchmark)
    puts "Creating school"
    super(meter_collection)
    @benchmark_type = benchmark_type
  end

  def name
    @benchmark_type.to_s
  end

  def aggregated_electricity_meters
    calculate_aggregated_meter(:electricity)
  end

  def aggregated_heat_meters
    calculate_aggregated_meter(:gas)
  end

  private

  def calculate_aggregated_meter(fuel_type)
    @aggregated_meters ||= {}
    @aggregated_meters[fuel_type] ||= create_benchmark_meter(fuel_type)
  end

  def create_benchmark_meter(fuel_type)
    puts "=" * 100
    puts "Calculating #{fuel_type} #{@benchmark_type}"
    original_meter = @original_school.aggregate_meter(fuel_type)
    return nil if original_meter.nil?

    benchmark_meter = SyntheticMeter.new(original_meter)

    calculator = AverageSchoolCalculator.new(@original_school)
    benchmark_meter.amr_data = calculator.benchmark_amr_data(meter: original_meter, benchmark_type: @benchmark_type)

    benchmark_meter.set_carbon_and_costs

    benchmark_meter
  end
end

require 'require_all'
require_relative 'virtual_school.rb'
# Given a list of 'average school's creates an average school
# also generates an exemplar school
#

class AverageSchoolAggregator < VirtualSchool
  include Logging

  attr_reader :aggregation_definition

  # aggregation_definition example:
  #
  # aggregation_definition = {
  #   name:       'Average School',
  #   urn:        123456789,
  #   floor_area: 1000.0,
  #   pupils:     200,
  #   schools: [
  #               { urn: 109089 },  # Paulton Junior
  #               { urn: 109328 },  # St Marks
  #               { urn: 109005 },  # St Johns
  #               { urn: 109081 }   # Castle
  #   ]
  # }
  def initialize(aggregation_definition)
    super(
      aggregation_definition[:name],
      aggregation_definition[:urn],
      aggregation_definition[:floor_area],
      aggregation_definition[:pupils],
      nil # area name needs setting from 1st school in list
    )
    @aggregation_definition = aggregation_definition
  end

  def self.simple_config(list_of_schools, name, urn, floor_area, pupils)
    config = {
      name:       name,
      urn:        urn,
      floor_area: floor_area,
      pupils:     pupils,
      schools:    list_of_schools
    }
    config
  end

  def calculate
    schools = AnalyticsLoadSchools.load_schools(@aggregation_definition[:schools])

    @name = concatenate_name(schools)
    @urn = aggregate_urn(schools)
    @area_name = schools[0].area_name

    create_school

    create_average_amr_data(schools)
  end

  private

  def create_average_amr_data(schools)
    bm = Benchmark.measure {
      average_amr_data(school, schools, :electricity, number_of_pupils)
      average_amr_data(school, schools, :gas, floor_area)
      AggregateDataService.new(school).aggregate_heat_and_electricity_meters
    }
    logger.info("Created average school from #{schools.length} schools in #{bm.to_s}")
  end

  def concatenate_name(schools)
    if @aggregation_definition.key?(:name) && !@aggregation_definition[:name].nil?
      @aggregation_definition[:name]
    else
    'Average of: ' + schools.map{ |school| school.name}.join(',')
    end
  end

  def aggregate_urn(schools)
    if @aggregation_definition.key?(:urn) && !@aggregation_definition[:urn].nil?
      @aggregation_definition[:urn]
    else
      schools.map { |school| school.urn }.inject(:+)
    end
  end

  # average, scaled back to average school's floor_area (gas) or pupils (electricity)
  def average_amr_data(average_school, schools, fuel_type, scale_up)
    amr_data_count = Hash.new(0.0)
    average_school_meter = aggregated_meter(average_school, fuel_type)
    average_amr_data = average_school_meter.amr_data

    schools.each do |school|
      meter = aggregated_meter(school, fuel_type)
      amr_data = meter.amr_data
      scaling_factor = fuel_type == :electricity ? (scale_up.to_f / number_of_pupils) : (scale_up.to_f / floor_area)

      (amr_data.start_date..amr_data.end_date).each do |date|
        average_amr_data.add(date, OneDayAMRReading.zero_reading(0, date, 'AGGR')) unless average_amr_data.date_exists?(date)
        average_amr_data[date] += OneDayAMRReading.scale(amr_data[date], scaling_factor)
        amr_data_count[date] += 1
      end
    end

    (average_amr_data.start_date..average_amr_data.end_date).each do |date|
      one_days_data = OneDayAMRReading.scale(average_amr_data[date], 1.0 / amr_data_count[date])
      one_days_data.set_meter_id(average_school_meter.mpan_mprn.to_s)
      average_amr_data.add(date, one_days_data)
    end
  end

  def aggregated_meter(meter_collection, fuel_type)
    fuel_type == :electricity ? meter_collection.electricity_meters[0] : meter_collection.heat_meters[0]
  end
end
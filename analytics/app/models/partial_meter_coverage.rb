require_rel './floor_area_pupil_numbers_base.rb'

class PartialMeterCoverage < FloorAreaPupilNumbersBase
  def initialize(partial_meter_attributes)
    super(partial_meter_attributes, :percent_floor_area, :percent_pupil_numbers)
  end

  def self.total_partial_floor_area(partial_meter_coverage, start_date = nil, end_date = nil)
    partial_floor_areas = to_array(partial_meter_coverage).map do |meter_partial_coverage|
      meter_partial_coverage.partial_floor_area(start_date, end_date)
    end
    partial_floor_areas.all?(&:nil?) ? 1.0 : partial_floor_areas.compact.sum
  end

  def self.total_partial_number_of_pupils(partial_meter_coverage, start_date = nil, end_date = nil)
    partial_number_of_pupils = to_array(partial_meter_coverage).map do |meter_partial_coverage|
      meter_partial_coverage.partial_number_of_pupils(start_date, end_date)
    end
    partial_number_of_pupils.all?(&:nil?) ? 1.0 : partial_number_of_pupils.compact.sum
  end

  def self.to_array(a)
    a.is_a?(Array) ? a : [a]
  end

  def partial_floor_area(start_date = nil, end_date = nil)
    @area_pupils_history.nil? ? nil : calculate_weighted_floor_area(start_date, end_date)
  end

  def partial_number_of_pupils(start_date = nil, end_date = nil)
    @area_pupils_history.nil? ? nil : calculate_weighted_number_of_pupils(start_date, end_date)
  end
end

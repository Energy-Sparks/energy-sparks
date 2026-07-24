# frozen_string_literal: true

class PartialMeterCoverage
  def initialize(partial_meter_attributes)
    @floor_area = FloorAreaPupilNumbersBase.new(partial_meter_attributes, :percent_floor_area, nil)
    @pupil_numbers = FloorAreaPupilNumbersBase.new(partial_meter_attributes, :percent_pupil_numbers, nil)
  end

  def self.total_partial_floor_area(partial_meter_coverage, start_date = nil, end_date = nil)
    total(partial_meter_coverage, start_date, end_date, :partial_floor_area)
  end

  def self.total_partial_number_of_pupils(partial_meter_coverage, start_date = nil, end_date = nil)
    total(partial_meter_coverage, start_date, end_date, :partial_number_of_pupils)
  end

  private_class_method def self.total(partial_meter_coverage, start_date, end_date, method)
    partial = Array(partial_meter_coverage).map do |meter_partial_coverage|
      meter_partial_coverage.send(method, start_date, end_date)
    end
    partial.all?(&:nil?) ? 1.0 : partial.compact.sum
  end

  private

  def partial_floor_area(start_date = nil, end_date = nil)
    @floor_area.value(start_date, end_date)
  end

  def partial_number_of_pupils(start_date = nil, end_date = nil)
    @pupil_numbers.value(start_date, end_date)
  end
end

# frozen_string_literal: true

class ComparisonOverviewComponent < ApplicationComponent
  include AdvicePageHelper

  attr_reader :school

  def initialize(school:, meter_collection:, id: nil, classes: '')
    super(id: id, classes: "comparison-overview-component #{classes}")
    @school = school
    @meter_collection = meter_collection
  end

  def can_benchmark_electricity?
    @school.has_electricity? && electricity_usage_service.enough_data?
  end

  def can_benchmark_gas?
    @school.has_gas? && gas_usage_service.enough_data?
  end

  def electricity_benchmarked_usage
    @electricity_benchmarked_usage ||= electricity_usage_service.benchmark_usage
  end

  def gas_benchmarked_usage
    @gas_benchmarked_usage ||= gas_usage_service.benchmark_usage
  end

  def render?
    @school.school_group.present?
  end

  private

  def gas_usage_service
    @gas_usage_service ||= usage_service(:gas)
  end

  def electricity_usage_service
    @electricity_usage_service ||= usage_service(:electricity)
  end

  def usage_service(fuel_type)
    Schools::Advice::LongTermUsageService.new(@school, @meter_collection, fuel_type)
  end
end

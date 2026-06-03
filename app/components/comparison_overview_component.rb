# frozen_string_literal: true

class ComparisonOverviewComponent < ApplicationComponent
  include AdvicePageHelper

  attr_reader :school

  def initialize(school:, aggregate_school_service:, **_kwargs)
    super
    @school = school
    @aggregate_school_service = aggregate_school_service
  end

  def can_benchmark_electricity?
    existing_benchmark?(:electricity)
  end

  def can_benchmark_gas?
    existing_benchmark?(:gas)
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

  # This is an alternative to doing, e.g:
  #
  # @school.has_electricity? && electricity_usage_service.enough_data?
  #
  # Instead check to see if we've already generated a benchmark assessment for this school using the LongTermUsageService.
  # If that exists then the school has the fuel type and enough data.
  #
  # Delays loading the meter collection from the Rails cache until we know we actually need it
  def existing_benchmark?(fuel_type)
    advice_page = AdvicePage.find_by_key("#{fuel_type}_long_term")
    @school.advice_page_school_benchmarks.where(advice_page:).any?
  end

  def gas_usage_service
    @gas_usage_service ||= usage_service(:gas)
  end

  def electricity_usage_service
    @electricity_usage_service ||= usage_service(:electricity)
  end

  def usage_service(fuel_type)
    Schools::Advice::LongTermUsageService.new(@school, @aggregate_school_service, fuel_type)
  end
end

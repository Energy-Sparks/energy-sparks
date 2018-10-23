class AmrDataValidatorAndAggregatorService
  def initialize(school)
    @school = school
  end

  def vaildate_and_aggregate_school
    meter_collection = AmrMeterCollection.new(school)
    AggregateDataService.new(meter_collection).validate_and_aggregate_meter_data
  end
end

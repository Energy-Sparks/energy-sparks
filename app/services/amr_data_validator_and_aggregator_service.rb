class AmrDataValidatorAndAggregatorService
  def aggregate_school(school)
    meter_collection = AmrMeterCollection.new(school)
    AggregateDataService.new(meter_collection).validate_and_aggregate_meter_data
  end
end

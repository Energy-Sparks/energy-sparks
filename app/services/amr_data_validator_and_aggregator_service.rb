class AmrDataValidatorAndAggregatorService
  def initialize(school)
    @school = school
    @meter_collection = AmrMeterCollection.new(@school)
  end

  def validate_and_aggregate_school
    AggregateDataService.new(@meter_collection).validate_and_aggregate_meter_data

    pp "Report for #{@school.name}"
    # meter collection now has all kinds of extra goodies
    @meter_collection.heat_meters.each do |meter|
      pp meter.to_s
      pp meter.amr_data.first
    end
    @meter_collection.electricity_meters.each do |meter|
      pp meter.to_s
    end
    @meter_collection
  end

  def persist_amr_readings
    validate_and_aggregate_school
    # @meter_collection.heat_meters.each do |meter|
    #   amr_data = meter.amr_data
    #   amr_data.values.each do |one_day_read|
    #     AmrReading.create_from_one_day_reading(one_day_read)
    #   end
    # end
    @meter_collection.electricity_meters.each do |meter|
      amr_data = meter.amr_data
      amr_data.values.each do |one_day_read|
        AmrReading.create_from_one_day_reading(one_day_read)
      end
    end
  end
end

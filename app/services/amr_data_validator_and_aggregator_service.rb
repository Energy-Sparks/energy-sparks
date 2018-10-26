class AmrDataValidatorAndAggregatorService
  def initialize(school)
    @school = school
    @meter_collection = AmrMeterCollection.new(@school)
  end

  def validate_and_aggregate_school
    AggregateDataService.new(@meter_collection).validate_and_aggregate_meter_data

    p "Report for #{@school.name}"
    # meter collection now has all kinds of extra goodies
    # @meter_collection.heat_meters.each do |meter|
    #   pp meter.to_s
    #   pp meter
    #   pp meter.amr_data.first
    # end
    # @meter_collection.electricity_meters.each do |meter|
    #   pp meter.to_s
    #   pp meter
    # end
    @meter_collection
  end

  def validate_school
    AggregateDataService.new(@meter_collection).validate_meter_data

    p "Report for #{@school.name}"
    @meter_collection
  end

  def persist_validated_amr_readings
    validate_school

    pp "ELECTRICITY METERS"
    @meter_collection.electricity_meters.each do |meter|
      Upsert.batch(AmrReading.connection, AmrReading.table_name) do |upsert|
        p meter.to_s
        amr_data = meter.amr_data
        amr_data.values.each do |one_day_read|
          AmrReading.upsert_from_one_day_reading(upsert, one_day_read)
        end
      end
    end
    pp "HEAT METERS"
    @meter_collection.heat_meters.each do |meter|
      p meter.to_s
      Upsert.batch(AmrReading.connection, AmrReading.table_name) do |upsert|
        amr_data = meter.amr_data
        amr_data.values.each do |one_day_read|
          AmrReading.upsert_from_one_day_reading(upsert, one_day_read)
        end
      end
    end
  end
end

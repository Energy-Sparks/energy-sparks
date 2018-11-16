module Amr
  class ValidateAndPersistReadingsService
    def initialize(school)
      @school = school
      @meter_collection = AmrMeterCollection.new(@school)
    end

    def perform
      p "Report for #{@school.name} #{@school.id}"
      AggregateDataService.new(@meter_collection).validate_meter_data

      pp "ELECTRICITY METERS"
      @meter_collection.electricity_meters.each do |meter|
        process_meter(meter)
      end
      pp "HEAT METERS"
      @meter_collection.heat_meters.each do |meter|
        process_meter(meter)
      end

      p "Report for #{@school.name}"
      @meter_collection
    end

  private

    def process_meter(meter)
      return if AmrDataFeedReading.where(meter_id: meter.id).empty?
      Upsert.batch(AmrValidatedReading.connection, AmrValidatedReading.table_name) do |upsert|
        amr_data = meter.amr_data
        amr_data.values.each do |one_day_read|
          upsert_from_one_day_reading(upsert, one_day_read)
        end
      end
    end

    def upsert_from_one_day_reading(upsert, one_day_reading)
      # If it's a substitute value, then it isn't going to know it's meter id - meter_id will
      # be set by the analytics code as the meter_no, i.e. MPAN/MPRN
      # TODO meter_id needs refactoring in back end analytics code
      meter_id = if one_day_reading.type != 'ORIG'
                   Meter.find_by(meter_no: one_day_reading.meter_id).id
                 else
                   one_day_reading.meter_id
                 end

      if meter_id.present?
        upsert.row({ meter_id: meter_id, reading_date: one_day_reading.date },
          meter_id: meter_id,
          reading_date: one_day_reading.date,
          kwh_data_x48: one_day_reading.kwh_data_x48,
          one_day_kwh: one_day_reading.one_day_kwh,
          substitute_date: one_day_reading.substitute_date,
          status: one_day_reading.type,
          upload_datetime: one_day_reading.upload_datetime
      )

      else
        pp "Can't insert, no meter_id #{one_day_reading}"
      end
    rescue ActiveRecord::InvalidForeignKey
      pp "Can't insert, missing meter for #{one_day_reading.meter_id}"
      pp one_day_reading
    end
  end
end

module Amr
  class UpsertValidatedReadingsForAMeter
    NAN_READINGS = Array.new(48, Float::NAN).freeze

    def initialize(dashboard_meter)
      @dashboard_meter = dashboard_meter
    end

    def perform
      Rails.logger.info "Processing: #{@dashboard_meter} with mpan_mprn: #{@dashboard_meter.mpan_mprn} id: #{@dashboard_meter.external_meter_id}"
      amr_data = @dashboard_meter.amr_data

      validated_amr_data = amr_data.delete_if {|_reading_date, one_day_read| is_nan?(one_day_read) }
      return if validated_amr_data.empty?

      do_upsert(convert_to_hash(validated_amr_data))

      Rails.logger.info "Upserted: #{@dashboard_meter}"
      @dashboard_meter.amr_data = validated_amr_data
      @dashboard_meter
    end

  private

    # Returns a PG::Result object
    def do_upsert(values)
      sql = create_custom_upsert(values)
      ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql(sql))
    end

    # Builds a custom upsert SQL statement for Postgres
    #
    # The Rails InsertAll class is used to create the SQL for an upsert_all or insert_all
    # It produces a query like: INSERT INTO...ON CONFLICT...DO UPDATE SET...RETURNING...
    #
    # But the implementation does not support, at least in Rails 6, the option to add a WHERE clause.
    #
    # Using a WHERE clause we can add a caveat to the DO UPDATE SET option to check the values we are
    # inserting against the value already in the database. This is represented by a special temporary
    # table called "excluded"
    #
    # This method uses the InsertAll class to build a basic UPSERT, then appends a WHERE clause and
    # RETURNING statement
    #
    # The result should be a method that will:
    # - insert any new records
    # - if any existing records are found for this meter and reading date
    #   - update the record if the values have changed
    #   - do nothing if the data hasnt changed
    #
    # This greatly reduces the number of updates as otherwise ALL conflicting rows trigger an update
    def create_custom_upsert(values)
      # Creates the InsertAll object as the upset_all method would do
      # We specify no returning to exclude that clause so we can add it in later
      insert_all = ActiveRecord::InsertAll.new(
        AmrValidatedReading.none,
        AmrValidatedReading.connection,
        values,
        on_duplicate: :update,
        unique_by: [:meter_id, :reading_date],
        returning: false)
      # Calling private method here, but means we can piggy-back off all the SQL creation
      insert = insert_all.send(:to_sql)
      where = <<-SQL.squish
        WHERE
          amr_validated_readings.kwh_data_x48 IS DISTINCT FROM excluded.kwh_data_x48 OR
          amr_validated_readings.one_day_kwh IS DISTINCT FROM excluded.one_day_kwh OR
          amr_validated_readings.status IS DISTINCT FROM excluded.status OR
          amr_validated_readings.substitute_date IS DISTINCT FROM excluded.substitute_date OR
          amr_validated_readings.upload_datetime IS DISTINCT FROM excluded.upload_datetime
      SQL
      "#{insert} #{where}"
    end

    def convert_to_hash(validated_amr_data)
      validated_amr_data.values.map do |one_day_reading|
        {
          meter_id: @dashboard_meter.external_meter_id,
          reading_date: one_day_reading.date,
          kwh_data_x48: one_day_reading.kwh_data_x48,
          one_day_kwh: one_day_reading.one_day_kwh,
          substitute_date: one_day_reading.substitute_date,
          status: one_day_reading.type,
          upload_datetime: one_day_reading.upload_datetime
        }
      end
    end

    def is_nan?(one_day_reading)
      one_day_reading.one_day_kwh == Float::NAN || one_day_reading.kwh_data_x48 == NAN_READINGS
    end
  end
end

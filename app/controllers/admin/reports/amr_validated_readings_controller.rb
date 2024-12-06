module Admin
  module Reports
    class AmrValidatedReadingsController < AdminController
      include CsvDownloader

      CSV_HEADER = 'School URN,School Name,Postcode,Meter Type,Mpan Mprn,Reading Date,One Day Total kWh,Status,Substitute Date,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,00:00'.freeze

      def show
        @amr_types = OneDayAMRReading::AMR_TYPES.dup
        @amr_types['MISSING'] = { name: 'No readings' }
        @colour_hash = Colours::AMR_COLOURS.each_with_index.map { |colour, index| [@amr_types.keys[index], colour] }.to_h
        @colour_hash['MISSING'] = Colours.chart_dark_orange
        @meter = Meter.includes(:amr_validated_readings).find(params[:meter_id])
        @school = @meter.school

        @first_validated_reading_date = @meter.first_validated_reading
        respond_to do |format|
          format.json do
            readings = @meter.amr_validated_readings.order(:reading_date)
            @reading_summary = readings.pluck(:reading_date, :status, :substitute_date).map do |reading_date, status, substitute_date|
              { reading_date => validated_reading_hash(status, substitute_date) }
            end
            # Turn array of hashes in to a proper hash
            @reading_summary = @reading_summary.inject(:merge!)
          end
          format.html do
            @gappy_validated_readings = @meter.gappy_validated_readings
          end
        end
      end

      def summary
        @meter = Meter.includes(:amr_validated_readings).find(params[:meter_id])
        @first_validated_reading_date = @meter.first_validated_reading
        respond_to do |format|
          format.json do
            readings = @meter.amr_validated_readings.order(:reading_date)
            @reading_summary = readings.pluck(:reading_date, :status, :one_day_kwh).map do |reading_date, status, one_day_kwh|
              { reading_date => summary_hash(status, one_day_kwh) }
            end
            # Turn array of hashes in to a proper hash
            @reading_summary = @reading_summary.inject(:merge!)
          end
        end
      end

    private

      def summary_hash(status, one_day_kwh)
        if status == 'ORIG'
          description = 'ORIG, uncorrected good data'
          colour = Colours.chart_green
        else
          description = 'Corrected/modified data'
          colour = '#3f7d69'
        end
        if one_day_kwh == 0 && status == 'ORIG'
          description = 'Zero usage, uncorrected original data'
          colour = '#5297c6'
        end
        if one_day_kwh == 0 && status != 'ORIG'
          description = 'Zero usage, corrected/modified data'
          colour = '#fcac21'
        end
        { description: description, colour: colour }
      end

      def validated_reading_hash(status, substitute_date)
        description = "#{status} #{@amr_types[status][:name]}"
        description = description + " (with #{substitute_date.strftime('%d/%m/%Y')})" if substitute_date
        colour = @colour_hash.key?(status) ? @colour_hash[status].to_s : Colours.grey_dark
        { description: description, colour: colour }
      end
    end
  end
end

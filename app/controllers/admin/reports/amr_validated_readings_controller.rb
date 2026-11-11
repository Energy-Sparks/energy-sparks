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
        respond_to do |format|
          format.json do
            @meter = Meter.includes(:amr_validated_readings).find(params[:meter_id])
            render json: Meters::DetailedCalendarGenerator.new(@meter).generate
          end
          format.html do
            summary_generator = Meters::SummarisedCalendarGenerator.new(@meter)
            @summary_legend = summary_generator.legend
            @detailed_legend = Meters::DetailedCalendarGenerator.new(@meter).legend
            @gappy_validated_readings = @meter.gappy_validated_readings
          end
        end
      end

      def summary
        @meter = Meter.includes(:amr_validated_readings).find(params[:meter_id])
        render json: Meters::SummarisedCalendarGenerator.new(@meter).generate
      end
    end
  end
end

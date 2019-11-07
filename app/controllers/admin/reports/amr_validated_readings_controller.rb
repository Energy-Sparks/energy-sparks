module Admin
  module Reports
    class AmrValidatedReadingsController < AdminController
      include CsvDownloader

      COLOUR_ARRAY = ['#5cb85c', "#9c3367", "#67347f", "#501e74", "#935fb8", "#e676a3", "#e4558b", "#7a9fb1", "#5297c6", "#97c086", "#3f7d69", "#6dc691", "#8e8d6b", "#e5c07c", "#e9d889", "#e59757", "#f4966c", "#e5644e", "#cd4851", "#bd4d65", "#515749", "#e5644e", "#cd4851", "#bd4d65", "#515749"].freeze
      CSV_HEADER = "School URN,Mpan Mprn,Reading Date,One Day Total kWh,Status,Substitute Date,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,00:00".freeze

      def index
        @school_groups = SchoolGroup.includes(:schools).where.not(schools: { id: nil }).order(:name)

        respond_to do |format|
          format.csv { send_data readings_to_csv(AmrValidatedReading.download_all_data, CSV_HEADER), filename: "all-amr-validated-readings.csv" }
          format.html
        end
      end

      def show
        @amr_types = OneDayAMRReading::AMR_TYPES
        @colour_hash = COLOUR_ARRAY.each_with_index.map { |colour, index| [@amr_types.keys[index], colour] }.to_h
        @meter = Meter.includes(:amr_validated_readings).find(params[:meter_id])

        @first_validated_reading_date = @meter.first_validated_reading
        respond_to do |format|
          format.json do
            readings = @meter.amr_validated_readings.order(:reading_date)
            @reading_summary = readings.pluck(:reading_date, :status, :substitute_date).map do |reading_date, status, substitute_date|
              { reading_date => summary_hash(status, substitute_date) }
            end
            # Turn array of hashes in to a proper hash
            @reading_summary = @reading_summary.inject(:merge!)
          end
          format.html
        end
      end

    private

      def summary_hash(status, substitute_date)
        description = "#{status} #{@amr_types[status][:name]}"
        description = description + " (with #{substitute_date.strftime('%d/%m/%Y')})" if substitute_date
        colour = @colour_hash[status].to_s
        { description: description, colour: colour }
      end
    end
  end
end

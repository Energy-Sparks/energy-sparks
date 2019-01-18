module Schools
  class MetersController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource through: :school

    CSV_HEADER = "Reading Date,One Day Total kWh,Status,SubstituteDate, 00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,24:00".freeze

    def index
      load_meters
      @meter = @school.meters.new
    end

    def show
      @meter = Meter.find(params[:id])
      respond_to do |format|
        format.csv { send_data amr_validated_meter_readings_to_csv, filename: "meter-amr-readings-#{@meter.mpan_mprn}.csv" }
      end
    end

    def create
      if @meter.save
        MeterManagement.new(@meter).process_creation!
        redirect_to school_meters_path(@school)
      else
        load_meters
        render :index
      end
    end

    def edit
    end

    def update
      if @meter.update(meter_params)
        if @meter.mpan_mprn_previously_changed?
          MeterManagement.new(@meter).process_mpan_mpnr_change!
        end
        redirect_to school_meters_path(@school), notice: 'Meter updated'
      else
        render :edit
      end
    end

    def deactivate
      @meter.update!(active: false)
      redirect_to school_meters_path(@school), notice: 'Meter deactivated'
    end

    def activate
      @meter.update!(active: true)
      redirect_to school_meters_path(@school), notice: 'Meter deactivated'
    end

    def destroy
      @meter.safe_destroy
      redirect_to school_meters_path(@school)
    rescue EnergySparks::SafeDestroyError => e
      redirect_to school_meters_path(@school), alert: "Delete failed: #{e.message}"
    end

  private

    def amr_validated_meter_readings_to_csv
      sql_query = <<~QUERY
        SELECT reading_date, one_day_kwh, status, substitute_date, kwh_data_x48
        FROM amr_validated_readings
        WHERE meter_id = #{@meter.id}
        ORDER BY reading_date ASC
      QUERY

      conn = ActiveRecord::Base.connection.raw_connection

      CSV.generate({}) do |csv|
        csv << CSV_HEADER.split(',')
        conn.copy_data "COPY (#{sql_query}) TO STDOUT WITH CSV;" do
          while (row = conn.get_copy_data)
            csv << row.tr('"', '').tr('{', '').tr('}', '').chomp.split(',')
          end
        end
      end
    end

    def load_meters
      @meters ||= @school.meters
      @active_meters = @meters.active.order(:mpan_mprn)
      @inactive_meters = @meters.inactive.order(:mpan_mprn)
      @invalid_mpan = @active_meters.select(&:electricity?).reject(&:correct_mpan_check_digit?)
    end

    def meter_params
      params.require(:meter).permit(:mpan_mprn, :meter_type, :name, :meter_serial_number)
    end
  end
end

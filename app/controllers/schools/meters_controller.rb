module Schools
  class MetersController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource through: :school

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
        csv << %w(ReadingDate OneDayKWHTotal Status SubstitutionDate)
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

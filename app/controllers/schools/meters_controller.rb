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
      @amr_validated_meter_readings = @meter.amr_validated_readings.order(:reading_date).to_a
      respond_to do |format|
        format.html
        format.xlsx { response.headers['Content-Disposition'] = "attachment; filename=meter-amr-readings-#{@meter.mpan_mprn}.xlsx" }
        format.csv { send_data amr_validated_meter_readings_to_csv }
      end
    end

    def amr_validated_meter_readings_to_csv
      CSV.generate({}) do |csv|
        csv << %w(ReadingDate OneDayKWHTotal SubstitutionDate Status)
        @amr_validated_meter_readings.each do |reading|
          row = [reading.reading_date, reading.one_day_kwh, reading.status, reading.substitute_date, *reading.kwh_data_x48]
          csv << row
        end
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

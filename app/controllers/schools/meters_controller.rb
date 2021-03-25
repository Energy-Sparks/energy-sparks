module Schools
  class MetersController < ApplicationController
    include CsvDownloader

    load_and_authorize_resource :school
    load_and_authorize_resource through: :school

    def index
      load_meters
      @meter = @school.meters.new
      @pending_reviews = meters_need_review?
      respond_to do |format|
        format.html
        format.csv { send_data readings_to_csv(AmrValidatedReading.download_query_for_school(@school), AmrValidatedReading::CSV_HEADER_FOR_SCHOOL), filename: "school-amr-readings-#{@school.name.parameterize}.csv" }
      end
    end

    def show
      @n3rgy_status = MeterManagement.new(@meter).check_n3rgy_status
      @elements = MeterManagement.new(@meter).elements
      respond_to do |format|
        format.html
        format.csv { send_data readings_to_csv(AmrValidatedReading.download_query_for_meter(@meter), AmrValidatedReading::CSV_HEADER_FOR_METER), filename: "meter-amr-readings-#{@meter.mpan_mprn}.csv" }
      end
    end

    def create
      manager = MeterManagement.new(@meter)
      if @meter.dcc_meter? && !manager.valid_dcc_meter?
        @meter.errors.add :base, "This meter is not registered with DCC"
        load_meters
        render :index
        return
      end
      if @meter.save
        manager.process_creation!
        redirect_to school_meters_path(@school)
      else
        load_meters
        render :index
      end
    end

    def edit
    end

    def update
      @meter.attributes = meter_params
      manager = MeterManagement.new(@meter)
      if @meter.dcc_meter? && !manager.valid_dcc_meter?
        @meter.errors.add :base, "This meter is not registered with DCC"
        render :edit
        return
      end
      if @meter.save
        if @meter.mpan_mprn_previously_changed?
          manager.process_mpan_mpnr_change!
        end
        redirect_to school_meters_path(@school), notice: 'Meter updated'
      else
        render :edit
      end
    end

    def inventory
      @inventory = Amr::N3rgyApiFactory.new.data_api(@meter).inventory(@meter.mpan_mprn)
      render :inventory
    rescue => e
      flash[:error] = e
      render :inventory
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
      MeterManagement.new(@meter).delete_meter!
      redirect_to school_meters_path(@school)
    end

  private

    def meters_need_review?
      @school.meters.unreviewed_dcc_meter.any?
    end

    def load_meters
      @meters ||= @school.meters
      @active_meters = @meters.active.real.order(:mpan_mprn)
      @inactive_meters = @meters.inactive.real.order(:mpan_mprn)
      @active_pseudo_meters = @meters.active.pseudo.order(:mpan_mprn)
      @inactive_pseudo_meters = @meters.inactive.pseudo.order(:mpan_mprn)
      @invalid_mpan = @active_meters.select(&:electricity?).reject(&:correct_mpan_check_digit?)
    end

    def meter_params
      params.require(:meter).permit(:mpan_mprn, :meter_type, :name, :meter_serial_number, :dcc_meter, :consent_granted, :sandbox, :earliest_available_data)
    end
  end
end

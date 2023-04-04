module Admin
  class MeterStatusesController < AdminController
    before_action :set_admin_meter_status, only: %i[edit update destroy]

    def index
      @admin_meter_statuses = AdminMeterStatus.all.order('LOWER(label)')
    end

    def new
      @admin_meter_status = AdminMeterStatus.new
    end

    def edit
    end

    def create
      @admin_meter_status = AdminMeterStatus.new(admin_meter_status_params)
      respond_to do |format|
        if @admin_meter_status.save
          format.html { redirect_to admin_meter_statuses_path, notice: "Meter status was successfully created." }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @admin_meter_status.update(admin_meter_status_params)
          format.html { redirect_to admin_meter_statuses_path, notice: "Meter status was successfully updated." }
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @admin_meter_status.destroy

      respond_to do |format|
        format.html { redirect_to admin_meter_statuses_path, notice: "Meter status was successfully deleted." }
      end
    end

    private

    def set_admin_meter_status
      @admin_meter_status = AdminMeterStatus.find(params[:id])
    end

    def admin_meter_status_params
      params.require(:admin_meter_status).permit(:label)
    end
  end
end

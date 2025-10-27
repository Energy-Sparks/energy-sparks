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
          format.html { redirect_to admin_meter_statuses_path, notice: 'Meter status was successfully created.' }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @admin_meter_status.update(admin_meter_status_params)
          format.html { redirect_to admin_meter_statuses_path, notice: 'Meter status was successfully updated.' }
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      respond_to do |format|
        # Delete button is hidden in the ui when there are associated meters and school groups but
        # this is left here as a fallback
        if @admin_meter_status.school_groups.count.zero? && @admin_meter_status.meters.count.zero?
          @admin_meter_status.destroy
          notice = 'Meter status was successfully deleted.'
        else
          notice = 'Meter status cannot be deleted while it has associated school groups or meters.'
        end
        format.html { redirect_to admin_meter_statuses_path, notice: notice }
      end
    end

    private

    def set_admin_meter_status
      @admin_meter_status = AdminMeterStatus.find(params[:id])
    end

    def admin_meter_status_params
      params.require(:admin_meter_status).permit(:label, :ignore_in_inactive_meter_report)
    end
  end
end

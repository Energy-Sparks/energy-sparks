module Admin
  class MeterStatusController < AdminController
    def index
      @meter_status = AdminMeterStatus.all
    end
  end
end

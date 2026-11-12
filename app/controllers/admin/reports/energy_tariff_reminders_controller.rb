# frozen_string_literal: true

module Admin
  module Reports
    class EnergyTariffRemindersController < AdminController
      before_action :enable_bootstrap5

      def index
        @report = EnergyTariffReminderReport.new
      end
    end
  end
end

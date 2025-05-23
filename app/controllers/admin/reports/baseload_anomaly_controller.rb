# frozen_string_literal: true

module Admin
  module Reports
    class BaseloadAnomalyController < AdminController
      def index
        @anomalies = Report::BaseloadAnomaly.all.with_meter_school_and_group.default_order
      end
    end
  end
end

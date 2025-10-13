# frozen_string_literal: true

module Admin
  module SchoolGroups
    class MeterReportsController < AdminController
      include ApplicationHelper

      load_and_authorize_resource :school_group

      def show
        respond_to do |format|
          format.html { @meters = meter_report.meters }
          format.csv { send_data meter_report.csv, filename: meter_report.csv_filename }
        end
      end

      def deliver
        if params[:data_report] == 'true'
          AdminMailer.with(to: current_user.email, school_group: @school_group).school_group_meter_data_report
                     .deliver_later
        else
          SchoolGroupMeterReportJob.perform_later(to: current_user.email, school_group: @school_group,
                                                  all_meters: params[:all_meters].present?)
        end
        redirect_back fallback_location: admin_school_group_path(@school_group),
                      notice: "Meter report for #{@school_group.name} requested to be sent to #{current_user.email}"
      end

      private

      def meter_report
        @meter_report ||= ::SchoolGroups::MeterReport.new(@school_group, all_meters: params[:all_meters].present?)
      end
    end
  end
end

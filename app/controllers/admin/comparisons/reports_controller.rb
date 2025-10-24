# frozen_string_literal: true

module Admin
  module Comparisons
    class ReportsController < AdminController
      include LocaleHelper

      load_and_authorize_resource :report, class: 'Comparison::Report'

      before_action :build_custom_period, only: %i[new create edit update]

      def index
        @reports = @reports.by_key
      end

      def create
        if @report.save
          redirect_to admin_comparisons_reports_path, notice: 'Report was successfully created.'
        else
          render :new
        end
      end

      def update
        if @report.update(report_params)
          redirect_to admin_comparisons_reports_path, notice: 'Report was successfully updated.'
        else
          render :edit
        end
      end

      def destroy
        @report.destroy
        redirect_to admin_comparisons_reports_path, notice: 'Report was successfully deleted.'
      end

      private

      def build_custom_period
        @report.custom_period || @report.build_custom_period
      end

      def report_params
        translated_params = t_params(Comparison::Report.mobility_attributes)
        params.require(:report).permit(
          translated_params,
          :reporting_period,
          :report_group_id,
          :title,
          :introduction,
          :notes,
          :public,
          :disabled,
          :fuel_type,
          custom_period_attributes: %i[current_label current_start_date current_end_date previous_label
                                       previous_start_date previous_end_date max_days_out_of_date enough_days_data
                                       disable_normalisation]
        )
      end
    end
  end
end

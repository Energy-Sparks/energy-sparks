# frozen_string_literal: true

module Admin
  module Comparisons
    class ReportGroupsController < AdminController
      include LocaleHelper

      load_and_authorize_resource :report_group, class: 'Comparison::ReportGroup'

      def index
        @report_groups = @report_groups.by_position
      end

      def create
        if @report_group.save
          redirect_to admin_comparisons_report_groups_path, notice: 'ReportGroup was successfully created.'
        else
          render :new
        end
      end

      def update
        if @report_group.update(report_group_params)
          redirect_to admin_comparisons_report_groups_path, notice: 'ReportGroup was successfully updated.'
        else
          render :edit
        end
      end

      def destroy
        @report_group.destroy
        redirect_to admin_comparisons_report_groups_path, notice: 'ReportGroup was successfully deleted.'
      end

      private

      def report_group_params
        translated_params = t_params(Comparison::ReportGroup.mobility_attributes)
        params.require(:report_group).permit(
          translated_params,
          :order
        )
      end
    end
  end
end

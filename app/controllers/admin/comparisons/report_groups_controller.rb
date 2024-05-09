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
          redirect_to admin_comparisons_report_groups_path, notice: 'Report group was successfully created.'
        else
          render :new
        end
      end

      def update
        if @report_group.update(report_group_params)
          redirect_to admin_comparisons_report_groups_path, notice: 'Report group was successfully updated.'
        else
          render :edit
        end
      end

      def destroy
        notice = if @report_group.destroy
                   'Report group was successfully deleted.'
                 else
                   "Unable to delete report group: #{@report_group.errors.full_messages.join(', ')}"
                 end
        redirect_to admin_comparisons_report_groups_path, notice: notice
      end

      private

      def report_group_params
        translated_params = t_params(Comparison::ReportGroup.mobility_attributes)
        params.require(:report_group).permit(
          translated_params,
          :position
        )
      end
    end
  end
end

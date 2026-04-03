# frozen_string_literal: true

module Admin
  module Reports
    class PupilNumberUpdatesController < AdminController
      def index
        @schools = schools_with_no_automated_update
        @schools = @schools.where(school_group_id: params[:school_group]) if params[:school_group].present?
        school_groups = { default_issues_admin_user_id: params[:user] }
        @schools = @schools.joins(:school_group).where(school_groups:) if params[:user].present?
      end

      private

      def schools_with_no_automated_update
        attributes_sql = SchoolMeterAttribute.active.floor_area_pupil_numbers
                                             .select('DISTINCT ON (school_id) *')
                                             .reorder(Arel.sql("school_id, input_data->>'start_date' DESC NULLS LAST"))
                                             .to_sql
        @schools = School.active.includes(:establishment)
                         .joins("LEFT JOIN (#{attributes_sql}) AS latest_attributes ON " \
                                'schools.id = latest_attributes.school_id')
                         .where('latest_attributes.reason IS NULL OR NOT starts_with(latest_attributes.reason, ?)',
                                ::Schools::PupilNumberUpdater::AUTOMATED_REASON)
                         .select(['schools.*',
                                  'latest_attributes.created_by_id AS latest_attribute_created_by_id',
                                  'latest_attributes.reason AS latest_attribute_reason'].join(', '))
      end

      def find_reasons(school)
        reasons = [('partial school' unless school.full_school),
                   ('admin set attribute' if school.latest_attribute_created_by_id.present?),
                   check_establishment(school)].compact
        reasons << school.latest_attribute_reason if reasons.empty?
        reasons
      end
      helper_method :find_reasons

      def check_establishment(school)
        if school.establishment_id.nil?
          'no associated DfE data'
        elsif school.establishment.number_of_pupils.nil?
          'no number of pupils in DfE data'
        elsif school.establishment.number_of_pupils.zero?
          'number of pupils is zero in DfE data'
        end
      end
    end
  end
end

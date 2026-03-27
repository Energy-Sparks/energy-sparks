# frozen_string_literal: true

module Admin
  module Reports
    class PupilNumberUpdatesController < AdminController
      def index; end

      private

      def find_reasons(school)
        if school.full_school
          attribute = last_attribute(school)
          return if attribute&.reason&.start_with?(::Schools::PupilNumberUpdater::AUTOMATED_REASON)
        end
        reasons = []
        reasons << 'partial school' unless school.full_school
        reasons << 'admin set attribute' if attribute&.created_by_id.present?
        reasons << check_establishment(school)
        reasons.compact
      end
      helper_method :find_reasons

      def last_attribute(school)
        school.meter_attributes.active.floor_area_pupil_numbers
              .order(Arel.sql("input_data->>'start_date' DESC NULLS LAST")).first
      end

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

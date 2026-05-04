# frozen_string_literal: true

module ImpactReports
  module EnergyEfficiency
    class FeaturedSchoolComponent < ImpactReports::BaseComponent
      def display?
        @config&.energy_efficiency_school &&
          (@config.energy_efficiency_school_expiry_date.blank? ||
          @config.energy_efficiency_school_expiry_date > Time.zone.today)
      end

      def school
        @school ||= display? ? @config.energy_efficiency_school : nil
      end

      def description
        @config.energy_efficiency_note
      end

      def image
        @config.energy_efficiency_image.attached? ? @config.energy_efficiency_image : 'for-multi-academies.jpg'
      end

      def render?
        school.present?
      end
    end
  end
end

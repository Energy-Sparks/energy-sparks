# frozen_string_literal: true

module Admin
  module Reports
    class EnergyTariffsController < AdminController
      def index
        @count_by_active_school_group = EnergyTariff.count_by_active_school_group
        @school_groups = school_groups

        respond_to do |format|
          format.html
          format.csv do
            @headers = headers
            response.headers['Content-Type'] = 'text/csv'
            response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
            render partial: 'table'
          end
        end
      end

      private

      def filename
        EnergySparks::Filenames.csv('energy_tariffs')
      end

      def headers
        ['School Group', 'Admin', 'Tariffs',
         'Current electricity tariff start date',
         'Current electricity tariff end date',
         'Current gas tariff start date',
         'Current gas tariff end date',
         'School electricity tariffs',
         'School gas tariffs']
      end

      def school_groups
        SchoolGroup.organisation_groups.with_visible_schools.order(:name)
      end
    end
  end
end

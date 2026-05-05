# frozen_string_literal: true

module Admin
  module Schools
    class LicencesController < AdminController
      load_and_authorize_resource :school

      layout 'dashboards'

      def index
        @licences = @school.licences.by_start_date
        current_licence = @school.licences.current.first
        return unless current_licence

        @price = ::Commercial::PriceCalculator.new.for_school(
          school: @school,
          contract: current_licence.contract
        )
        @renewal_price = ::Commercial::PriceCalculator.new.for_school_renewal(school: @school)
      end
    end
  end
end

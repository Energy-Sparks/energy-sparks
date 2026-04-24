# frozen_string_literal: true

module Admin
  module Schools
    class LicencesController < AdminController
      load_and_authorize_resource :school

      layout 'dashboards'

      def index
        @licences = @school.licences.by_start_date
        @price = ::Commercial::PriceCalculator.new.for_school_renewal(school: @school)
      end
    end
  end
end

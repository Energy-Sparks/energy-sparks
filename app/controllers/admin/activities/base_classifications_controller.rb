# frozen_string_literal: true

module Admin
  module Activities
    class BaseClassificationsController < BaseController
      before_action :add_breadcrumbs

      private

      def set_tab
        @tab = controller_name
      end

      def set_country
        @country = Enums::Country::ENUM_COUNTRY.keys.find { |country| country.to_s == params[:country].to_s } ||
                   Enums::Country::ENUM_COUNTRY.keys.first
      end

      def add_breadcrumbs
        @breadcrumbs << { name: controller_name.humanize }
      end
    end
  end
end

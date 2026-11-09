# frozen_string_literal: true

module Admin
  module Activities
    module WithCountry
      extend ActiveSupport::Concern

      included do
        before_action :set_country
        before_action :add_breadcrumbs
      end

      private

      def set_country
        @country = Enums::Country::ENUM_COUNTRY.keys.find { |country| country.to_s == params[:country].to_s } ||
                   Enums::Country::ENUM_COUNTRY.keys.first
      end

      def add_breadcrumbs
        @breadcrumbs << { name: 'Activities', href: admin_activities_classifications_path(task_type: 'activity') }
        @breadcrumbs << { name: controller_name.humanize }
      end
    end
  end
end

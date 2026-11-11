# frozen_string_literal: true

module Admin
  module Activities
    class CountryTabsComponent < ApplicationComponent
      attr_reader :country, :resource_class

      def initialize(country:, resource_class:, **_kwargs)
        @country = country
        @resource_class = resource_class
        super
      end

      def countries
        Enums::Country::ENUM_COUNTRY.values
      end

      def path_for(country_option)
        helpers.polymorphic_path([:admin, :activities, resource_route], country: country_option)
      end

      def active?(country_option)
        country.to_s == country_option.to_s
      end

      private

      # model_name.route_key includes the namespace for Activities::SubjectArea, so use the element
      def resource_route
        resource_class.model_name.element.pluralize.to_sym
      end
    end
  end
end

# frozen_string_literal: true

module Admin
  module Tasks
    class ClassificationTabsComponent < ApplicationComponent
      COUNTRY_SCOPED = %i[subject_areas learning_stages].freeze

      attr_reader :current, :country

      def initialize(current:, country: nil, **_kwargs)
        @current = current.to_s
        @country = country
        super
      end

      def tabs
        action? ? Task::Label::ACTION_TYPES : Task::Label::ACTIVITY_TYPES + COUNTRY_SCOPED
      end

      def name_for(key)
        key.to_s.pluralize.humanize
      end

      def path_for(key)
        case key.to_sym
        when :subject_areas then helpers.admin_activities_subject_areas_path(**country_params)
        when :learning_stages then helpers.admin_activities_learning_stages_path(**country_params)
        else helpers.admin_activities_labels_path(label_type: key)
        end
      end

      def active?(key)
        key == current.to_sym
      end

      def new_label
        "New #{current.singularize.humanize.downcase}"
      end

      def new_path
        case current.to_sym
        when :subject_areas then helpers.new_admin_activities_subject_area_path(**country_params)
        when :learning_stages then helpers.new_admin_activities_learning_stage_path(**country_params)
        else helpers.new_admin_activities_label_path(label_type: current)
        end
      end

      private

      def action?
        Task::Label::ACTION_TYPES.include?(current.to_sym)
      end

      def country_params
        return {} unless country

        { country: country }
      end
    end
  end
end

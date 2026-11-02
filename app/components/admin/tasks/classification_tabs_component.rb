# frozen_string_literal: true

module Admin
  module Tasks
    class ClassificationTabsComponent < ApplicationComponent
      attr_reader :current

      def initialize(current:, **_kwargs)
        @current = current.to_s
        super
      end

      def tabs
        action? ? Task::Label::ACTION_TYPES : Task::Label::ACTIVITY_TYPES
      end

      def name_for(key)
        key.to_s.pluralize.humanize
      end

      def path_for(key)
        helpers.admin_activities_labels_path(label_type: key)
      end

      def active?(key)
        key == current.to_sym
      end

      def new_label
        "New #{current}"
      end

      def new_path
        helpers.new_admin_activities_label_path(label_type: current)
      end

      private

      def action?
        Task::Label::ACTION_TYPES.include?(current.to_sym)
      end
    end
  end
end

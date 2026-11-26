# frozen_string_literal: true

module Layout
  module Cards
    class Task < LayoutComponent
      COUNTRIES = Enums::Country::ENUM_COUNTRY.keys.freeze
      private_constant :COUNTRIES

      attr_reader :task, :country

      def initialize(task:, country: :england, show_summary: false, **_kwargs)
        super
        @task = task
        @country = country.to_s.downcase.to_sym
        @show_summary = show_summary
        validate_inclusion country: @country, in: COUNTRIES
      end

      def activity_type?
        task.is_a?(ActivityType)
      end

      def activities_index?
        Flipper.enabled?(:activities_index, current_user)
      end

      def show_summary?
        @show_summary
      end

      private

      def learning_stages
        task.learning_stages.for_country(country).by_name
      end

      def key_stages
        task.key_stages.by_name
      end

      def subject_areas
        task.subject_areas.for_country(country).by_name
      end

      def subjects
        task.subjects.by_name
      end

      def durations
        task.durations.by_name
      end

      def task_theme
        task.public_type == :activity ? :accent : :light
      end

      def subject_area_tooltip
        t("activity_types.subject_area_label.#{country}")
      end
    end
  end
end

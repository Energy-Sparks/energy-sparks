# frozen_string_literal: true

module Meters
  class ReadingCalendarComponent < ApplicationComponent
    def initialize(meter:, calendar_generator:, path:, **)
      super(**)
      @meter = meter
      @path = path
      @calendar_generator = calendar_generator
    end

    def before_render
      view_context.content_for(:head) do
        helpers.javascript_import_module_tag('readings/calendar')
      end
    end

    private

    def legend
      @calendar_generator.legend
    end
  end
end

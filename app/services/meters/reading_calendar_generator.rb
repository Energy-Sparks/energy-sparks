# frozen_string_literal: true

module Meters
  # Produce a set of that can be serialised to JSON consistent with bootstrap-year-calendar
  class ReadingCalendarGenerator
    DEFAULT_LEGEND = {
      'MISSING' => { description: 'No readings', color: 'rgb(255,69,0)' }
    }.freeze

    def initialize(meter)
      @meter = meter
    end

    def generate
      {
        calendar_events: generate_events
      }
    end

    def legend
      generate_legend.merge({ 'rgb(255,69,0)' => 'No readings' })
    end

    private

    def generate_legend
      {}
    end

    def generate_events
      reading_summary = summarise_readings
      (first_reading_date..Time.zone.today).map do |date|
        event = {
          'startDate' => date,
          'endDate' => date
        }
        if reading_summary.key?(date)
          event[:name] = reading_summary[date][:description]
          event[:color] = reading_summary[date][:colour]
        else
          event[:name] = 'No readings'
          event[:color] = 'rgb(255,69,0)'
        end
        event
      end
    end

    def first_reading_date
      nil
    end

    def summarise_readings
      {}
    end
  end
end

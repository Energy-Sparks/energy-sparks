# frozen_string_literal: true

module Admin
  class LocalDistributionZonesController < AdminCrudController
    MODEL = LocalDistributionZone
    include Columns
    def index
      respond_to do |format|
        format.html
        format.csv { send_csv }
      end
    end

    def show
      @colours = { missing: :grey_dark, 38 => :teal_medium, 39 => :yellow_medium, 40 => :red_medium }
      @first_reading = @resource.readings.by_date.first
      respond_to do |format|
        format.html
        format.json do
          readings = @resource.readings.pluck(:date, :calorific_value).to_h
          calendar_events = (@first_reading.date..Date.current).map do |date|
            value = readings[date]
            { startDate: date, endDate: date, name: value || 'Missing',
              color: Colours.hex(@colours[value ? calorific_colour(value) : :missing]) }
          end
          render json: { calendar_events: }.to_json
        end
      end
    end

    private

    def send_csv
      columns = [
        Column.new(:zone_name,
                   ->(reading) { reading.local_distribution_zone.name }),
        Column.new(:zone_code,
                   ->(reading) { reading.local_distribution_zone.code }),
        Column.new('Zone Publication ID',
                   ->(reading) { reading.local_distribution_zone.publication_id }),
        Column.new(:date,
                   ->(reading) { reading.date }),
        Column.new(:calorific_value,
                   ->(reading) { reading.calorific_value })
      ]
      send_data csv_report(columns, LocalDistributionZoneReading.by_date.order(:local_distribution_zone_id)),
                filename: EnergySparks::Filenames.csv('LDZ-readings-report')
    end

    def calorific_colour(value)
      if value >= 40.0
        40
      elsif value >= 39.0
        39
      else
        38
      end
    end
  end
end

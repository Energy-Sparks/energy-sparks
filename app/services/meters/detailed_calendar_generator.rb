# frozen_string_literal: true

module Meters
  class DetailedCalendarGenerator < ReadingCalendarGenerator
    def initialize(meter)
      super
      @amr_types = OneDayAMRReading::AMR_TYPES.dup
      @amr_types['MISSING'] = { name: 'No readings' }

      @colour_hash = Colours::AMR_COLOURS.each_with_index.to_h { |colour, index| [@amr_types.keys[index], colour] }
    end

    private

    def generate_legend
      legend = @colour_hash.to_h do |type, colour|
        [colour, @amr_types[type][:name].to_s + (type == 'MISSING' ? '' : "(#{type})")]
      end
      legend[Colours.grey_dark] = 'Other corrections and substitutions'
      legend
    end

    def first_reading_date
      @meter.first_validated_reading
    end

    def summarise_readings
      readings = @meter.amr_validated_readings.order(:reading_date)
      reading_summary = readings.pluck(:reading_date, :status,
                                       :substitute_date).map do |reading_date, status, substitute_date|
        { reading_date => validated_reading_hash(status, substitute_date) }
      end
      # Turn array of hashes in to a proper hash
      reading_summary.inject(:merge!)
    end

    def validated_reading_hash(status, substitute_date)
      description = "#{status} #{@amr_types[status][:name]}"
      description += " (with #{substitute_date.strftime('%d/%m/%Y')})" if substitute_date
      colour = @colour_hash.key?(status) ? @colour_hash[status].to_s : Colours.grey_dark
      { description: description, colour: colour }
    end
  end
end

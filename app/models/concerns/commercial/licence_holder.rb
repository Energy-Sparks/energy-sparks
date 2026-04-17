# frozen_string_literal: true

module Commercial
  module LicenceHolder
    extend ActiveSupport::Concern

    included do
      has_many :licences, class_name: 'Commercial::Licence', dependent: :restrict_with_exception

      scope :without_current_licence, lambda {
        where.not(
          id: Commercial::Licence.current.select(:school_id)
        )
      }
    end

    def current_licence
      licences.current.by_start_date.first
    end

    def licenced_for?(date)
      licences.any? { |licence| date.between?(licence.start_date, licence.end_date) }
    end

    def currently_licenced?(today = Time.zone.today)
      licenced_for?(today)
    end

    # Do licences cover a whole period, part of it, or none?
    #
    # Returns:
    #   :no    – no licence overlaps the period at all
    #   :partial – some overlap, but not full coverage
    #   :full    – the entire period is covered by one or more licences
    def licenced_for_period(period)
      # Collect all overlapping licence ranges
      overlapping = licences.filter_map do |licence|
        licence_range = (licence.start_date..licence.end_date)
        next unless licence_range.overlaps?(period)

        licence_range
      end

      return :no if overlapping.empty?

      # Merge overlapping ranges to see if they cover the whole period
      merged = merge_ranges(overlapping)

      fully_covered =
        merged.any? { |range| range.begin <= period.begin && range.end >= period.end }

      fully_covered ? :full : :partial
    end

    private

    # Merge overlapping Ruby Range objects into minimal set
    def merge_ranges(ranges)
      sorted = ranges.sort_by(&:begin)
      merged = [sorted.shift]

      sorted.each do |range|
        last = merged.last
        # range overlaps so extend to latest end
        if range.begin <= last.end + 1.day
          merged[-1] = (last.begin..[last.end, range.end].max)
        else
          merged << range
        end
      end

      merged
    end
  end
end

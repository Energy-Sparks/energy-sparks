# frozen_string_literal: true

require 'dashboard'

module Amr
  class AnalyticsSchoolFactory
    def initialize(active_record_school)
      @active_record_school = active_record_school
    end

    def build
      attributes = @active_record_school.attributes.symbolize_keys
      attributes.merge({
                         floor_area:,
                         country:,
                         funding_status:,
                         school_times: @active_record_school.school_times_to_analytics,
                         community_use_times: @active_record_school.community_use_times_to_analytics,
                         location:
                       })
    end

    private

    def country
      @active_record_school.country ? @active_record_school.country.to_sym : :england
    end

    def funding_status
      case @active_record_school.funding_status
      when 'private_school'
        :private
      else
        :state
      end
    end

    def location
      [@active_record_school.latitude, @active_record_school.longitude]
    end

    def floor_area
      @active_record_school.floor_area.to_f
    end
  end
end

# school: defines a school
#         currently derives from Building
#           - TODO(PH,JJ,3Jun18) - at some point decide whether
#           - this is the correct model
#
require_relative '../../../lib/dashboard'

module Dashboard
  class School
    # Activation date is when the school was activated by an administrator in the Energy Sparks front end - it is a date
    # Created at is when the school was created during the onboarding process - it is a timestamp
    ATTRIBUTES = %i[name id address floor_area number_of_pupils school_type area_name postcode country
                    funding_status created_at school_times community_use_times location data_enabled has_swimming_pool]
                 .freeze
    attr_reader(*ATTRIBUTES)
    attr_accessor :urn

    def initialize(data)
      data = { area_name: 'Bath', school_times: [], community_use_times: [], location: [], data_enabled: true }
             .merge(data)
      (ATTRIBUTES + %i[urn activation_date]).each do |key|
        instance_variable_set("@#{key}", data[key])
      end
    end

    def latitude
      return nil if @location.nil?

      @location[0].to_f
    end

    def longitude
      return nil if @location.nil?

      @location[1].to_f
    end

    def activation_date
      return nil if @activation_date.nil?

      # the time is passed in as an active_support Time and not a ruby Time
      # from the front end, so can't be used directly, the utc field needs to be accessed
      # instead
      t = @activation_date.respond_to?(:utc) ? @activation_date.utc : @activation_date
      Date.new(t.year, t.month, t.day)
    end

    def creation_date
      return nil if @created_at.nil?

      # the time is passed in as an active_support Time and not a ruby Time
      # from the front end, so can't be used directly, the utc field needs to be accessed
      # instead
      t = @created_at.respond_to?(:utc) ? @created_at.utc : @created_at
      Date.new(t.year, t.month, t.day)
    end

    def to_s
      "#{name} - #{urn} - #{school_type} - #{area_name} - Activated: #{activation_date} - Created: #{created_at}"
    end
  end
end

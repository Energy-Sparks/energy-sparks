# frozen_string_literal: true

module Report
  module SolarMeter
    private_class_method def self.active_attribute(type, relation = 'meter_attributes')
      "AND #{relation}.attribute_type = '#{type}'
        AND #{relation}.replaced_by_id IS NULL
        AND #{relation}.deleted_by_id IS NULL"
    end

    private_class_method def self.first_attribute_subquery(type)
      "SELECT id FROM meter_attributes
        WHERE meter_id = meters.id
        #{active_attribute(type)}"
    end

    private_class_method def self.solar_attribute_join(type)
      "JOIN meter_attributes solar_attributes
       ON solar_attributes.meter_id = meters.id
       #{active_attribute(type, :solar_attributes)}"
    end

    private_class_method def self.query
      Meter.joins(school: :school_group)
           .where(schools: { active: true })
           .includes(:data_source, :supplier, :admin_meter_status,
                     school: { school_group: %i[admin_meter_status_electricity default_issues_admin_user] })
    end

    def self.metered
      query.joins(solar_attribute_join(:solar_pv_mpan_meter_mapping))
           .select('meters.*',
                   'solar_attributes.input_data AS solar_attribute_data',
                   "EXISTS (#{first_attribute_subquery(:solar_pv_override)}) AS has_solar_pv_override_attribute",
                   "EXISTS (#{first_attribute_subquery(:solar_pv)}) AS has_solar_pv_attribute",
                   "EXISTS (#{first_attribute_subquery(:modelled_solar_pv_generation)}) " \
                   'AS has_modelled_solar_pv_generation_attribute')
    end

    def self.metered_school_ids
      Meter.joins(solar_attribute_join(:solar_pv_mpan_meter_mapping)).pluck(:school_id)
    end

    def self.modelled
      query.joins(solar_attribute_join(:solar_pv))
           .select('meters.*',
                   'solar_attributes.input_data AS solar_attribute_data')
    end

    def self.modelled_school_ids
      Meter.joins(solar_attribute_join(:solar_pv)).pluck(:school_id)
    end
  end
end

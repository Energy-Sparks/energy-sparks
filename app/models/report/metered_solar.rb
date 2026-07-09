# frozen_string_literal: true

module Report
  module MeteredSolar
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

    def self.query
      Meter.joins(school: :school_group)
           .joins("JOIN meter_attributes solar_pv_mapping_attributes
                    ON solar_pv_mapping_attributes.meter_id = meters.id
                    #{active_attribute(:solar_pv_mpan_meter_mapping, :solar_pv_mapping_attributes)}")
           .where(schools: { active: true })
           .select('meters.*',
                   'solar_pv_mapping_attributes.input_data AS solar_pv_mapping_data',
                   "EXISTS (#{first_attribute_subquery(:solar_pv_override)}) AS has_solar_pv_override_attribute",
                   "EXISTS (#{first_attribute_subquery(:solar_pv)}) AS has_solar_pv_attribute",
                   "EXISTS (#{first_attribute_subquery(:modelled_solar_pv_generation)}) " \
                   'AS has_modelled_solar_pv_generation_attribute')
           .includes(:data_source, :supplier, :admin_meter_status,
                     school: { school_group: %i[admin_meter_status_electricity default_issues_admin_user] })
    end
  end
end

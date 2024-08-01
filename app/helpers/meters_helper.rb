# frozen_string_literal: true

module MetersHelper
  def consented_in_n3rgy?(list_of_consented_mpans, meter)
    return nil if list_of_consented_mpans.empty?

    list_of_consented_mpans.include? meter.mpan_mprn.to_s
  end

  def highlight_consent_mismatch?(list_of_consented_mpans, meter)
    return false if list_of_consented_mpans.empty?

    meter.consent_granted && !consented_in_n3rgy?(list_of_consented_mpans, meter)
  end

  def meter_defaults_json(school, data_source_id, procurement_route_id, admin_meter_statuses_id)
    defaults = %i[electricity gas solar_pv].to_h do |type|
      id_values = [data_source_id, procurement_route_id, admin_meter_statuses_id].zip(
        %i[default_data_source default_procurement_route admin_meter_statuses]
      ).map do |id, method|
        { id:, value: school&.school_group&.method(:"#{method}_#{type}_id")&.call }
      end
      [type, id_values]
    end
    defaults[:exported_solar_pv] = defaults[:solar_pv]
    defaults.to_json.html_safe
  end

  def icon_and_display_name(meter)
    "#{fa_icon(fuel_type_icon(meter.meter_type))} #{meter.display_name}".html_safe
  end

  def options_for_meter_selection(meters)
    options = []
    meters.each do |meter|
      options << [meter.display_name, meter.mpan_mprn]
      options << ["#{meter.mpan_mprn} :mains_consume", "#{meter.mpan_mprn}|mains_consume"] if meter.has_solar_array?
    end
    options
  end
end

module MetersHelper
  def consented_in_n3rgy?(list_of_consented_mpans, meter)
    return nil if list_of_consented_mpans.empty?
    list_of_consented_mpans.include? meter.mpan_mprn.to_s
  end

  def highlight_consent_mismatch?(list_of_consented_mpans, meter)
    return false if list_of_consented_mpans.empty?
    meter.consent_granted && !consented_in_n3rgy?(list_of_consented_mpans, meter)
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

module MetersHelper
  def consented_in_n3rgy?(list_of_consented_mpans, meter)
    return nil if list_of_consented_mpans.empty?

    list_of_consented_mpans.include? meter.mpan_mprn
  end

  def highlight_consent_mismatch?(list_of_consented_mpans, meter)
    return false if list_of_consented_mpans.empty?

    !meter.sandbox && meter.consent_granted && !consented_in_n3rgy?(list_of_consented_mpans, meter)
  end
end

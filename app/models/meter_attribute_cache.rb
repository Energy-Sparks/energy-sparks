class MeterAttributeCache
  def self.analytics_meter_attributes
    @analytics_meter_attributes ||= YAML.load_file('etc/meter_attributes.yml')
  end

  def self.for(urn, mpan_mprn)
    analytics_meter_attributes.fetch(urn) { { meter_attributes: {} } }[:meter_attributes].fetch(mpan_mprn) { {} }
  end

  def self.pseudo_for(urn)
    analytics_meter_attributes.fetch(urn) { { pseudo_meter_attributes: {} } }.fetch(:pseudo_meter_attributes) {}
  end
end

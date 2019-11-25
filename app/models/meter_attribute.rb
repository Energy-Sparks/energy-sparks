class MeterAttribute
  class_attribute :analytics_meter_attributes

  def self.for(urn, mpan_mprn)
    analytics_meter_attributes.fetch(urn) { { meter_attributes: {} } }[:meter_attributes].fetch(mpan_mprn) { {} }
  end

  def self.pseudo_for(urn)
    analytics_meter_attributes.fetch(urn) { { pseudo_meter_attributes: {} } }.fetch(:pseudo_meter_attributes) {}
  end
end

module ParentMeterAttributeHolder
  extend ActiveSupport::Concern

  def meter_attributes_for(meter)
    if EnergySparks::FeatureFlags.active?(:new_energy_tariff_editor)
      meter_attributes.where('meter_types ? :meter_type', meter_type: meter.meter_type).where.not(attribute_type: GlobalMeterAttribute::TARIFF_ATTRIBUTE_TYPES).active
    else
      meter_attributes.where('meter_types ? :meter_type', meter_type: meter.meter_type).active
    end
  end

  def pseudo_meter_attributes
    filtered_meter_attributes.active.inject({}) do |collection, attribute|
      attribute.selected_meter_types.select {|selected| attribute.pseudo?(selected)}.each do |meter_type|
        collection[meter_type] ||= []
        collection[meter_type] << attribute
      end
      collection
    end
  end

  private

  def filtered_meter_attributes
    if EnergySparks::FeatureFlags.active?(:new_energy_tariff_editor)
      meter_attributes.where.not(attribute_type: GlobalMeterAttribute::TARIFF_ATTRIBUTE_TYPES)
    else
      meter_attributes
    end
  end
end

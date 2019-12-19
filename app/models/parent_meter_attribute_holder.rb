module ParentMeterAttributeHolder
  extend ActiveSupport::Concern

  def meter_attributes_for(meter)
    meter_attributes.where('meter_types ? :meter_type', meter_type: meter.meter_type).active
  end

  def pseudo_meter_attributes
    meter_attributes.inject({}) do |collection, attribute|
      attribute.selected_meter_types.select {|_type| attribute.pseudo?(meter_type)}.each do |meter_type|
        collection[meter_type] ||= []
        collection[meter_type] << attribute
      end
      collection
    end
  end
end

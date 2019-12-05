class SchoolMeterAttribute < ApplicationRecord
  belongs_to :school

  METER_TYPES = [:electricity, :gas].freeze

  def to_analytics
    meter_attribute_type.parse(input_data).to_analytics
  end

  def name
    meter_attribute_type.attribute_name
  end

  def description
    meter_attribute_type.attribute_description
  end

  def aggregation
    meter_attribute_type.attribute_aggregation
  end

  def structure
    meter_attribute_type.attribute_structure
  end

  def meter_attribute_type
    MeterAttributes.all[attribute_type.to_sym]
  end
end

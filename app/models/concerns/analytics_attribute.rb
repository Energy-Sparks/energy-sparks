module AnalyticsAttribute
  extend ActiveSupport::Concern

  included do
    belongs_to :replaced_by, class_name: name, optional: true
    belongs_to :deleted_by, class_name: 'User', optional: true
    belongs_to :created_by, class_name: 'User', optional: true
    has_one :replaces, class_name: name, foreign_key: :replaced_by_id

    scope :active,  -> { where(replaced_by_id: nil, deleted_by_id: nil) }
    scope :deleted, -> { where(replaced_by_id: nil).where.not(deleted_by_id: nil) }
  end

  def to_analytics
    meter_attribute_type.parse(input_data).to_analytics
  end

  def meter_attribute_type
    MeterAttributes.all[attribute_type.to_sym]
  end

  def pseudo?
    meter_attribute_type.applicable_attribute_pseudo_meter_types.include?(meter_type.to_sym)
  end
end

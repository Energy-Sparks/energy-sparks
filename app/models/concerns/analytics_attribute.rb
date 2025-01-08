module AnalyticsAttribute
  extend ActiveSupport::Concern

  included do
    belongs_to :replaced_by, class_name: name, optional: true
    belongs_to :deleted_by, class_name: 'User', optional: true
    belongs_to :created_by, class_name: 'User', optional: true
    has_one :replaces, class_name: name, foreign_key: :replaced_by_id

    scope :active,  -> { where(replaced_by_id: nil, deleted_by_id: nil).order(created_at: :asc)}
    scope :deleted, -> { where(replaced_by_id: nil).where.not(deleted_by_id: nil).order(created_at: :asc)}

    validate :input_data_valid

    after_save :invalidate_school_cache
  end

  def to_analytics
    meter_attribute_type.parse(input_data).to_analytics
  end

  def meter_attribute_type
    MeterAttributes.all[attribute_type.to_sym]
  end

  def selected_meter_types
    (meter_types || []).reject(&:blank?).map(&:to_sym)
  end

  def pseudo?(meter_type)
    meter_attribute_type&.applicable_attribute_pseudo_meter_types&.include?(meter_type.to_sym)
  end

  def input_data_valid
    return if input_data.blank?
    meter_attribute_type.parse(input_data)
  rescue => e
    errors.add(:input_data, e.message)
  end
end

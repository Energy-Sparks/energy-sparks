# == Schema Information
#
# Table name: alert_types
#
#  analysis      :text
#  class_name    :text
#  description   :text             not null
#  frequency     :integer
#  fuel_type     :integer
#  has_variables :boolean          default(FALSE)
#  id            :bigint(8)        not null, primary key
#  show_ratings  :boolean          default(TRUE)
#  sub_category  :integer
#  title         :text
#

class AlertType < ApplicationRecord
  has_many :alerts,                     dependent: :destroy
  has_many :alert_subscription_events,  dependent: :destroy

  has_many :alert_type_activity_types
  has_many :activity_types, through: :alert_type_activity_types
  has_many :ratings, class_name: 'AlertTypeRating'

  enum fuel_type: [:electricity, :gas]
  enum sub_category: [:hot_water, :heating, :baseload]
  enum frequency: [:termly, :weekly, :before_each_holiday]

  scope :electricity,   -> { where(fuel_type: :electricity) }
  scope :gas,           -> { where(fuel_type: :gas) }
  scope :no_fuel,       -> { where(fuel_type: nil) }

  validates_presence_of :description

  accepts_nested_attributes_for :alert_type_activity_types, reject_if: proc {|attributes| attributes['position'].blank? }

  def display_fuel_type
    return 'No fuel type' if fuel_type.nil?
    fuel_type.humanize
  end

  def cleaned_template_variables
    # TODO: make the analytics code remove the £ sign
    class_name.constantize.front_end_template_variables.deep_transform_keys do |key|
      :"#{key.to_s.gsub('£', 'gbp')}"
    end
  end

  def update_activity_type_positions!(position_attributes)
    transaction do
      alert_type_activity_types.destroy_all
      update!(alert_type_activity_types_attributes: position_attributes)
    end
  end

  def ordered_activity_types
    activity_types.order('alert_type_activity_types.position').group('activity_types.id, alert_type_activity_types.position')
  end
end

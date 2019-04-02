class AlertTypeActivityType < ApplicationRecord
  belongs_to :activity_type
  belongs_to :alert_type

  validates :activity_type, :alert_type, presence: true
end

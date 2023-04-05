class AdminMeterStatus < ApplicationRecord
  has_many :meters, foreign_key: 'admin_meter_statuses_id'
  has_many :school_groups, foreign_key: 'admin_meter_statuses_id'
end

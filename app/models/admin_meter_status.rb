# == Schema Information
#
# Table name: admin_meter_statuses
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  label      :string
#  updated_at :datetime         not null
#
class AdminMeterStatus < ApplicationRecord
  has_many :meters, foreign_key: 'admin_meter_statuses_id'
  has_many :school_groups_electricity, class_name: 'SchoolGroup', foreign_key: 'admin_meter_statuses_electricity_id'
  has_many :school_groups_gas, class_name: 'SchoolGroup', foreign_key: 'admin_meter_statuses_gas_id'
  has_many :school_groups_solar_pv, class_name: 'SchoolGroup', foreign_key: 'admin_meter_statuses_solar_pv_id'

  def school_groups
    SchoolGroup.where('admin_meter_statuses_electricity_id = :id OR admin_meter_statuses_gas_id = :id OR admin_meter_statuses_solar_pv_id = :id', id: id)
  end
end

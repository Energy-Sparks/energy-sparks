# == Schema Information
#
# Table name: school_target_events
#
#  created_at :datetime         not null
#  event      :integer          not null
#  id         :bigint(8)        not null, primary key
#  school_id  :bigint(8)        not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_school_target_events_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
class SchoolTargetEvent < ApplicationRecord
  belongs_to :school

  #first_target_sent: have we invited them to set their first target?
  #review_target_sent: have we asked them to set a new target?
  # x_added/x_removed: meters of fuel type added/removed
  enum event: {
    first_target_sent: 0,
    review_target_sent: 10,
    storage_heater_added: 20,
    storage_heater_removed: 25,
    electricity_added: 30,
    electricity_removed: 35,
    gas_added: 40,
    gas_removed: 45
  }

  #all events that are about fuel type changes
  def self.all_fuel_type_events
    [:storage_heater_added,
     :storage_heater_removed,
     :electricity_added,
     :electricity_removed,
     :gas_added,
     :gas_removed]
  end

  def self.fuel_types_changed?(school)
    fuel_type_events(school).any?
  end

  def self.fuel_types_changed(school)
    fuel_type_events(school).map {|e| e.delete_suffix("_added").delete_suffix("_removed")}
  end

  def self.fuel_type_events(school)
    (school.school_target_events.map(&:event) & all_fuel_type_events.map(&:to_s))
  end
end

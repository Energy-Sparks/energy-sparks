# == Schema Information
#
# Table name: secr_co2_equivalences
#
#  created_at                     :datetime         not null
#  electricity_co2e               :float
#  electricity_co2e_co2           :float
#  id                             :bigint(8)        not null, primary key
#  natural_gas_co2e               :float
#  natural_gas_co2e_co2           :float
#  transmission_distribution_co2e :float
#  updated_at                     :datetime         not null
#  year                           :integer
#
# Indexes
#
#  index_secr_co2_equivalences_on_year  (year) UNIQUE
#
class SecrCo2Equivalence < ApplicationRecord
  validates :electricity_co2e, presence: true, numericality: { greater_than: 0, less_than: 1 }
  validates :electricity_co2e_co2, presence: true, numericality: { greater_than: 0, less_than: 1 }
  validates :natural_gas_co2e, presence: true, numericality: { greater_than: 0, less_than: 1 }
  validates :natural_gas_co2e_co2, presence: true, numericality: { greater_than: 0, less_than: 1 }
  validates :transmission_distribution_co2e, presence: true, numericality: { greater_than: 0, less_than: 1 }
  validates :year, presence: true, uniqueness: true, numericality: { greater_than: 2020, less_than: 2050 }

  def self.human_attribute_name(attribute, options = {})
    name = super
    name.sub!('co2e co2', 'kg CO₂ equivalence of CO₂')
    name.sub!('co2e', 'kg CO₂ equivalence')
    name
  end
end

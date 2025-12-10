# frozen_string_literal: true

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
  # sourced from condensed set file on
  # https://www.gov.uk/government/collections/government-conversion-factors-for-company-reporting
  # UK electricity sheet, Electricity generated
  validates :electricity_co2e, presence: true, numericality: { greater_than: 0, less_than: 1 }
  # next to above
  validates :electricity_co2e_co2, presence: true, numericality: { greater_than: 0, less_than: 1 }
  # Fuels sheet, Natural Gas, kWh (Gross CV)
  validates :natural_gas_co2e, presence: true, numericality: { greater_than: 0, less_than: 1 }
  # next to above
  validates :natural_gas_co2e_co2, presence: true, numericality: { greater_than: 0, less_than: 1 }
  # Transmission and distribution sheet
  validates :transmission_distribution_co2e, presence: true, numericality: { greater_than: 0, less_than: 1 }
  validates :year, presence: true, uniqueness: true, numericality: { greater_than: 2020, less_than: 2050 }

  def self.factor(year, type)
    find_by(year:)&.public_send(type)
  end

  def self.co2e_co2(year)
    equivalence = find_by!(year:)
    { electricity: equivalence.electricity_co2e_co2, gas: equivalence.natural_gas_co2e_co2 }
  end
end

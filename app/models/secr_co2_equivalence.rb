# == Schema Information
#
# Table name: secr_co2_equivalences
#
#  created_at                     :datetime         not null
#  electricity_co2e               :float
#  id                             :bigint(8)        not null, primary key
#  natural_gas_co2e               :float
#  transmission_distribution_co2e :float
#  updated_at                     :datetime         not null
#  year                           :integer
#
class SecrCo2Equivalence < ApplicationRecord
end

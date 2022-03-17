# == Schema Information
#
# Table name: estimated_annual_consumptions
#
#  created_at      :datetime         not null
#  electricity     :float
#  gas             :float
#  id              :bigint(8)        not null, primary key
#  school_id       :bigint(8)        not null
#  storage_heaters :float
#  updated_at      :datetime         not null
#  year            :integer          not null
#
# Indexes
#
#  index_estimated_annual_consumptions_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
class EstimatedAnnualConsumption < ApplicationRecord
  belongs_to :school

  validates_presence_of :school, :year
  validate :must_have_one_estimate

  def must_have_one_estimate
    if electricity.blank? && gas.blank? && storage_heaters.blank?
      errors.add :base, "At least one estimate must be provided"
    end
  end
end

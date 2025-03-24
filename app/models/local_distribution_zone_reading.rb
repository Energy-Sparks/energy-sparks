# frozen_string_literal: true

# == Schema Information
#
# Table name: local_distribution_zone_readings
#
#  calorific_value            :float            not null
#  created_at                 :datetime         not null
#  date                       :date             not null
#  id                         :bigint(8)        not null, primary key
#  local_distribution_zone_id :bigint(8)
#  updated_at                 :datetime         not null
#
# Indexes
#
#  idx_on_local_distribution_zone_id_5bc550f347       (local_distribution_zone_id)
#  idx_on_local_distribution_zone_id_date_acca36ccf1  (local_distribution_zone_id,date) UNIQUE
#
class LocalDistributionZoneReading < ApplicationRecord
  belongs_to :local_distribution_zone
  scope :by_date, -> { order(:date) }
end

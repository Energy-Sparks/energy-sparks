# frozen_string_literal: true

# == Schema Information
#
# Table name: local_distribution_zones
#
#  code           :string           not null
#  created_at     :datetime         not null
#  id             :bigint(8)        not null, primary key
#  name           :string           not null
#  publication_id :string           not null
#  updated_at     :datetime         not null
#
class LocalDistributionZone < ApplicationRecord
  scope :by_name, -> { order(:name) }
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: local_distribution_zone_postcodes
#
#  id                         :bigint(8)        not null, primary key
#  local_distribution_zone_id :bigint(8)
#  postcode                   :string
#
# Indexes
#
#  idx_on_local_distribution_zone_id_a9dfd2a021         (local_distribution_zone_id)
#  index_local_distribution_zone_postcodes_on_postcode  (postcode) UNIQUE
#
class LocalDistributionZonePostcode < ApplicationRecord
  belongs_to :local_distribution_zone
  validates :postcode, presence: true, uniqueness: true

  def self.zone_id_for_school(school)
    outcode, incode = school.postcode.upcase.delete(' ').split(/(.{3})$/, 2)
    find_by(postcode: "#{outcode} #{incode}")&.local_distribution_zone_id ||
      find_by_max_tally("#{outcode} %") || find_by_max_tally("#{outcode.sub(/\d+$/, '')}%")
  end

  private_class_method def self.find_by_max_tally(term)
    where('postcode LIKE ?', term).pluck(:local_distribution_zone_id)
                                  .tally.max_by { |_, count| count }&.first
  end
end

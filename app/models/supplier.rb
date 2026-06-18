# frozen_string_literal: true

# == Schema Information
#
# Table name: suppliers
#
#  id          :bigint(8)        not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owned_by_id :integer
#
# Indexes
#
#  index_suppliers_on_name  (name) UNIQUE
#
class Supplier < ApplicationRecord
  include Deletable

  belongs_to :owned_by, class_name: :User, optional: true

  validates :name, presence: true, uniqueness: true

  has_many :meters, dependent: :nullify
  has_many :schools, -> { distinct }, through: :meters
  has_many :issues, as: :issueable, dependent: :destroy
  has_many :active_meter_issues, -> { merge(Meter.active).distinct }, through: :meters, source: :issues

  def self.by_name
    order(:name)
  end

  def deletable?
    meters.active.none?
  end
end

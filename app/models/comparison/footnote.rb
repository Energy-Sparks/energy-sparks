# == Schema Information
#
# Table name: comparison_footnotes
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  key        :string           not null
#  label      :string
#  updated_at :datetime         not null
#
# Indexes
#
#  index_comparison_footnotes_on_key  (key) UNIQUE
#
class Comparison::Footnote < ApplicationRecord
  self.table_name = 'comparison_footnotes'

  extend Mobility

  translates :description, type: :string, fallbacks: { cy: :en }

  validates :label, :description, presence: true
  validates :key, presence: true, uniqueness: true

  scope :by_label, ->(order = :asc) { order(label: order) }
  scope :by_key, ->(order = :asc) { order(key: order) }

  def t(params = {})
    description % params
  end

  def self.fetch(key)
    find_by(key: key)
  end

  def self.t(key, params = {})
    fetch(key).t(params)
  end
end

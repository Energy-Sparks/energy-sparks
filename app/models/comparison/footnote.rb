# == Schema Information
#
# Table name: comparison_footnotes
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  key        :string           not null
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

  validates :key, presence: true, uniqueness: true
  validates :description, presence: true
end

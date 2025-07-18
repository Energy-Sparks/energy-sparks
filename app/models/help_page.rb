# == Schema Information
#
# Table name: help_pages
#
#  created_at :datetime         not null
#  feature    :integer          not null
#  id         :bigint(8)        not null, primary key
#  published  :boolean          default(FALSE), not null
#  slug       :string           not null
#  title      :string
#  updated_at :datetime         not null
#
# Indexes
#
#  index_help_pages_on_slug  (slug) UNIQUE
#
class HelpPage < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: %i[finders slugged history]

  extend Mobility
  include TransifexSerialisable
  translates :title, type: :string, fallbacks: { cy: :en }
  translates :description, backend: :action_text

  validates :title, :feature, presence: true
  validates :feature, uniqueness: true

  scope :published,            -> { where(published: true) }
  scope :by_title,             -> { i18n.order(title: :asc) }

  enum :feature, { school_targets: 0,
                   live_data: 1,
                   management_summary_overview: 2,
                   annual_usage_estimate: 3 }
end

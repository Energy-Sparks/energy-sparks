# == Schema Information
#
# Table name: help_pages
#
#  created_at :datetime         not null
#  feature    :integer          not null
#  id         :bigint(8)        not null, primary key
#  published  :boolean          default(FALSE), not null
#  slug       :string           not null
#  title      :string           not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_help_pages_on_slug  (slug) UNIQUE
#
class HelpPage < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: [:finders, :slugged, :history]
  has_rich_text :description

  validates_presence_of :title, :feature
  validates_uniqueness_of :feature

  scope :published,            -> { where(published: true) }
  scope :by_title,             -> { order(title: :asc) }

  enum feature: {
    school_targets: 0
  }
end

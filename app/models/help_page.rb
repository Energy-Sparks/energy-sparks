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

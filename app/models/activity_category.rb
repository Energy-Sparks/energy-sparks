# == Schema Information
#
# Table name: activity_categories
#
#  created_at  :datetime         not null
#  description :string
#  featured    :boolean          default(FALSE)
#  id          :bigint(8)        not null, primary key
#  name        :string
#  pupil       :boolean          default(FALSE)
#  updated_at  :datetime         not null
#

class ActivityCategory < ApplicationRecord
  has_many :activity_types
  validates_presence_of :name
  validates_uniqueness_of :name

  has_one_attached :image

  scope :by_name, -> { order(name: :asc) }
  scope :featured, -> { where(featured: true) }
  scope :pupil, -> { where(pupil: true) }

  def self.listed_with_activity_types
    all.order(:name).map {|category| [category, category.activity_types.custom_last.order(:name).to_a]}
  end
end

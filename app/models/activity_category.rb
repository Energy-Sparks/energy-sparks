# == Schema Information
#
# Table name: activity_categories
#
#  created_at  :datetime         not null
#  description :string
#  featured    :boolean          default(FALSE)
#  icon        :string           default("question-circle")
#  id          :bigint(8)        not null, primary key
#  live_data   :boolean          default(FALSE)
#  name        :string
#  pupil       :boolean          default(FALSE)
#  updated_at  :datetime         not null
#

class ActivityCategory < ApplicationRecord
  extend Mobility
  include TransifexSerialisable
  include TranslatableAttachment

  translates :name, type: :string, fallbacks: { cy: :en }
  translates :description, type: :string, fallbacks: { cy: :en }

  has_many :activity_types
  validates_presence_of :name
  validates_uniqueness_of :name

  t_has_one_attached :image

  scope :by_name, -> { i18n.order(name: :asc) }
  scope :featured, -> { where(featured: true) }
  scope :pupil, -> { where(pupil: true) }
  scope :live_data, -> { where(live_data: true) }

  def self.listed_with_activity_types
    by_name.map {|category| [category, category.activity_types.custom_last.order(:name).to_a]}
  end
end

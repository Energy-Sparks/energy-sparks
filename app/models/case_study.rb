# == Schema Information
#
# Table name: case_studies
#
#  created_at  :datetime         not null
#  id          :bigint(8)        not null, primary key
#  position    :integer          default(0), not null
#  school_type :integer
#  title       :string
#  updated_at  :datetime         not null
#
class CaseStudy < ApplicationRecord
  extend Mobility
  include TransifexSerialisable
  include TranslatableAttachment
  include Enums::SchoolType

  scope :without_images, -> {
    left_outer_joins(:image_attachment).where(active_storage_attachments: { id: nil })
  }

  translates :title, type: :string, fallbacks: { cy: :en }
  translates :description, backend: :action_text

  has_one_attached :image # assume this doesn't need to be translatable
  t_has_one_attached :file

  validates :title, :file_en, presence: true
  validates :position, numericality: true, presence: true

  def file_locale(current_locale)
    current_locale.to_sym == :cy && t_attached(:file, :cy).present? ? :cy : :en
  end
end

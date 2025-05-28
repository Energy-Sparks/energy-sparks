# == Schema Information
#
# Table name: case_studies
#
#  created_at        :datetime         not null
#  id                :bigint(8)        not null, primary key
#  organisation_type :integer          default("school"), not null
#  position          :integer          default(0), not null
#  title             :string
#  updated_at        :datetime         not null
#
class CaseStudy < ApplicationRecord
  extend Mobility
  include TransifexSerialisable
  include TranslatableAttachment

  scope :without_images, -> {
    left_outer_joins(:image_attachment).where(active_storage_attachments: { id: nil })
  }

  # These need checking! Might be too fine grained for our needs
  enum :organisation_type, {
    school: 0, # default
    primary: 1,
    secondary: 2,
    special: 3,
    infant: 4,
    junior: 5,
    middle: 6,
    mixed_primary_and_secondary: 7,
    school_group: 8, # this is for "general"
    local_authority: 9,
    multi_academy_trust: 10,
  }

  translates :title, type: :string, fallbacks: { cy: :en }
  translates :description, backend: :action_text

  has_one_attached :image # assume this doesn't need to be translatable
  t_has_one_attached :file

  validates :title_en, :file_en, :organisation_type, presence: true
  validates :position, numericality: true, presence: true

  def organisation_type_label
    self.class.human_enum_name(:organisation_type, organisation_type)
  end

  def file_locale
    I18n.locale.to_sym == :cy && t_attached(:file, :cy).present? ? :cy : :en
  end
end

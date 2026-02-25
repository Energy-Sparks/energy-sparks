# == Schema Information
#
# Table name: case_studies
#
#  created_at    :datetime         not null
#  created_by_id :bigint(8)
#  id            :bigint(8)        not null, primary key
#  position      :integer          default(0), not null
#  published     :boolean          default(FALSE), not null
#  title         :string
#  updated_at    :datetime         not null
#  updated_by_id :bigint(8)
#
# Indexes
#
#  index_case_studies_on_created_by_id  (created_by_id)
#  index_case_studies_on_updated_by_id  (updated_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id) ON DELETE => nullify
#  fk_rails_...  (updated_by_id => users.id) ON DELETE => nullify
#

class CaseStudy < ApplicationRecord
  extend Mobility
  include TransifexSerialisable
  include TranslatableAttachment
  include Publishable
  include Trackable

  has_many :testimonials, dependent: :restrict_with_error

  scope :without_images, -> {
    left_outer_joins(:image_attachment).where(active_storage_attachments: { id: nil })
  }

  translates :title, type: :string, fallbacks: { cy: :en }

  # it was decided to keep tags in a string field for now, rather than a seperate model
  translates :tags, type: :string, fallbacks: { cy: :en }
  translates :description, backend: :action_text
  t_has_one_attached :file
  has_one_attached :image

  validates :image,
              content_type: ['image/png', 'image/jpeg'],
              dimension: { width: { min: 640, max: 1400 } } # betwen half and full container width size to be conservative
  validates :image, presence: true, if: :publishing?

  validates :title_en, :file_en, presence: true
  validates :position, numericality: true, presence: true

  def tag_list
    return [] if tags.blank?
    self.tags.split(',').map(&:strip)
  end

  # Sanitise tags input to ensure no leading/trailing spaces and no empty tag
  I18n.available_locales.each do |locale|
    define_method("tags_#{locale}=") do |tags_string|
      tags_string ||= ''
      super(tags_string.split(',').map(&:strip).reject(&:blank?).join(', '))
    end
  end

  def file_locale
    I18n.locale.to_sym == :cy && t_attached(:file, :cy).present? ? :cy : :en
  end
end

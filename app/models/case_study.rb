# == Schema Information
#
# Table name: case_studies
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  position   :integer          default(0), not null
#  title      :string
#  updated_at :datetime         not null
#

class CaseStudy < Cms::Base
  extend Mobility
  include TransifexSerialisable
  include TranslatableAttachment

  scope :without_images, -> {
    left_outer_joins(:image_attachment).where(active_storage_attachments: { id: nil })
  }

  translates :title, type: :string, fallbacks: { cy: :en }
  translates :tags, type: :string, fallbacks: { cy: :en }
  translates :description, backend: :action_text

  has_one_attached :image # assume this doesn't need to be translatable
  t_has_one_attached :file

  validates :title_en, :file_en, presence: true
  validates :position, numericality: true, presence: true

  def tag_list
    return [] if tags.blank?
    self.tags.split(',').map(&:strip)
  end

  # Sanitise tags input to ensure no leading/trailing spaces and no empty tag
  I18n.available_locales.each do |locale|
    define_method("tags_#{locale}=") do |tags_string|
      super(tags_string.split(',').map(&:strip).reject(&:blank?).join(', '))
    end
  end

  def file_locale
    I18n.locale.to_sym == :cy && t_attached(:file, :cy).present? ? :cy : :en
  end
end

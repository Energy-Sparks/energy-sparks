# == Schema Information
#
# Table name: cms_sections
#
#  created_at    :datetime         not null
#  created_by_id :bigint(8)
#  id            :bigint(8)        not null, primary key
#  page_id       :bigint(8)
#  position      :integer
#  published     :boolean          default(FALSE), not null
#  slug          :string           not null
#  updated_at    :datetime         not null
#  updated_by_id :bigint(8)
#
# Indexes
#
#  index_cms_sections_on_created_by_id  (created_by_id)
#  index_cms_sections_on_page_id        (page_id)
#  index_cms_sections_on_updated_by_id  (updated_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id) ON DELETE => nullify
#  fk_rails_...  (page_id => cms_pages.id)
#  fk_rails_...  (updated_by_id => users.id) ON DELETE => nullify
#
module Cms
  class Section < Cms::Base
    extend FriendlyId

    self.table_name = 'cms_sections'

    friendly_id :title, use: %i[finders slugged history]

    translates :title, type: :string, fallbacks: { cy: :en }
    translates :body, backend: :action_text

    belongs_to :page, class_name: 'Cms::Page', optional: true

    before_validation :set_default_position, on: [:create, :update]

    validates :position, numericality: { greater_than: 0, allow_nil: true }
    validates :position, uniqueness: { scope: :page_id }

    # virtual attribute for handling deletes from forms
    attr_accessor :_delete

    scope :positioned, -> { order(position: :asc) }
    scope :by_category_and_page, -> { joins(:page, { page: :category }).i18n.order(category_id: :asc, page_id: :asc, position: :asc) }

    private

    def set_default_position
      if position.nil?
        max_position = page.sections.maximum(:position) || 0
        self.position = max_position + 1
      end
    end
  end
end

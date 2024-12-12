# == Schema Information
#
# Table name: cms_sections
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  page_id    :bigint(8)        not null
#  position   :integer          default(0), not null
#  published  :boolean          default(FALSE), not null
#  slug       :string           not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_cms_sections_on_page_id  (page_id)
#
# Foreign Keys
#
#  fk_rails_...  (page_id => cms_pages.id)
#
module Cms
  class Section < Cms::Base
    extend FriendlyId

    self.table_name = 'cms_sections'

    friendly_id :title, use: %i[finders slugged history]

    translates :title, type: :string, fallbacks: { cy: :en }
    translates :body, backend: :action_text

    belongs_to :page, class_name: 'Cms::Page'
    scope :positioned, -> { order(position: :asc) }
  end
end

# == Schema Information
#
# Table name: cms_pages
#
#  category_id :bigint(8)        not null
#  created_at  :datetime         not null
#  id          :bigint(8)        not null, primary key
#  published   :boolean          default(FALSE), not null
#  slug        :string           not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_cms_pages_on_category_id  (category_id)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => cms_categories.id)
#
module Cms
  class Page < Cms::Base
    extend FriendlyId

    self.table_name = 'cms_pages'

    friendly_id :title, use: %i[finders slugged history]

    translates :title, type: :string, fallbacks: { cy: :en }
    translates :description, backend: :action_text

    belongs_to :category, class_name: 'Cms::Category'
    has_many :sections, class_name: 'Cms::Section', dependent: :restrict_with_error
  end
end

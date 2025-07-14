# == Schema Information
#
# Table name: cms_categories
#
#  created_at    :datetime         not null
#  created_by_id :bigint(8)
#  icon          :string
#  id            :bigint(8)        not null, primary key
#  published     :boolean          default(FALSE), not null
#  slug          :string           not null
#  updated_at    :datetime         not null
#  updated_by_id :bigint(8)
#
# Indexes
#
#  index_cms_categories_on_created_by_id  (created_by_id)
#  index_cms_categories_on_updated_by_id  (updated_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id) ON DELETE => nullify
#  fk_rails_...  (updated_by_id => users.id) ON DELETE => nullify
#
module Cms
  class Category < Cms::Base
    extend FriendlyId

    self.table_name = 'cms_categories'

    friendly_id :title, use: %i[finders slugged history]

    translates :title, type: :string, fallbacks: { cy: :en }
    translates :description, type: :string, fallbacks: { cy: :en }

    validates_presence_of :title, :description

    has_many :pages, class_name: 'Cms::Page', dependent: :restrict_with_error

    def self.publishable_error_without
      'without any published pages'
    end

    def publishable?
      pages.published.any?
    end
  end
end

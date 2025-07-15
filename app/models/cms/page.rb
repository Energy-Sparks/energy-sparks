# == Schema Information
#
# Table name: cms_pages
#
#  audience      :enum             default("anyone"), not null
#  category_id   :bigint(8)        not null
#  created_at    :datetime         not null
#  created_by_id :bigint(8)
#  id            :bigint(8)        not null, primary key
#  published     :boolean          default(FALSE), not null
#  slug          :string           not null
#  updated_at    :datetime         not null
#  updated_by_id :bigint(8)
#
# Indexes
#
#  index_cms_pages_on_category_id    (category_id)
#  index_cms_pages_on_created_by_id  (created_by_id)
#  index_cms_pages_on_updated_by_id  (updated_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => cms_categories.id)
#  fk_rails_...  (created_by_id => users.id) ON DELETE => nullify
#  fk_rails_...  (updated_by_id => users.id) ON DELETE => nullify
#
module Cms
  class Page < Cms::Base
    extend FriendlyId

    self.table_name = 'cms_pages'

    friendly_id :title, use: %i[finders slugged history]

    translates :title, type: :string, fallbacks: { cy: :en }
    translates :description, type: :string, fallbacks: { cy: :en }

    enum(:audience, %w[anyone school_users school_admins group_admins].to_h { |v| [v, v] })

    validates_presence_of :title, :description

    belongs_to :category, class_name: 'Cms::Category'
    has_many :sections, class_name: 'Cms::Section', dependent: :nullify

    scope :by_category_and_title, -> { i18n.order(category_id: :asc, title: :asc) }

    accepts_nested_attributes_for :sections

    def self.publishable_error_without
      'without any published sections'
    end

    def publishable?
      sections.published.any?
    end
  end
end

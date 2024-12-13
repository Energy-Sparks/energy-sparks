# == Schema Information
#
# Table name: cms_categories
#
#  created_at :datetime         not null
#  icon       :string
#  id         :bigint(8)        not null, primary key
#  published  :boolean          default(FALSE), not null
#  slug       :string           not null
#  updated_at :datetime         not null
#
module Cms
  class Category < Cms::Base
    extend FriendlyId

    self.table_name = 'cms_categories'
    friendly_id :title, use: %i[finders slugged history]

    translates :title, type: :string, fallbacks: { cy: :en }
    translates :description, type: :string, fallbacks: { cy: :en }

    has_many :pages, class_name: 'Cms::Page', dependent: :restrict_with_error
  end
end

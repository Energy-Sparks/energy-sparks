module Cms
  class Base < ApplicationRecord
    extend Mobility

    self.abstract_class = true

    belongs_to :created_by, class_name: 'User', optional: true
    belongs_to :updated_by, class_name: 'User', optional: true

    validates :title, presence: true

    scope :published, -> { where(published: true) }
    scope :by_title, ->(order = :asc) { i18n.order(title: order) }

    def publishable?
      true
    end
  end
end

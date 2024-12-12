module Cms
  class Base < ApplicationRecord
    extend Mobility

    self.abstract_class = true

    validates :title, presence: true

    scope :published, -> { where(published: true) }
    scope :by_title, ->(order = :asc) { i18n.order(title: order) }
  end
end

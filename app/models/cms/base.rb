module Cms
  class Base < ApplicationRecord
    extend Mobility
    include TransifexSerialisable
    include Publishable
    include Trackable

    self.abstract_class = true

    validates :title, presence: true

    scope :by_title, ->(order = :asc) { i18n.order(title: order) }
  end
end

module Cms
  class Base < ApplicationRecord
    extend Mobility
    include TransifexSerialisable

    self.abstract_class = true

    belongs_to :created_by, class_name: 'User', optional: true
    belongs_to :updated_by, class_name: 'User', optional: true

    validates :title, presence: true

    scope :published, -> { where(published: true) }
    scope :by_title, ->(order = :asc) { i18n.order(title: order) }
    scope :tx_resources, -> { published.order(:id) }

    def publishable?
      true
    end

    private

    # only allow changing publication status if we're unpublishing something
    # or if its publishable
    def change_publication_status?
      if published_changed?(from: false, to: true) && !publishable?
        errors.add(:published, 'cannot publish category without any published pages')
      end
    end
  end
end

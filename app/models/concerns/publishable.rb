module Publishable
  extend ActiveSupport::Concern

  included do
    belongs_to :created_by, class_name: 'User', optional: true
    belongs_to :updated_by, class_name: 'User', optional: true

    scope :published, -> { where(published: true) }
  end

  def publishable?
    true
  end

  private

  # only allow changing publication status if we're unpublishing something
  # or if its publishable
  def change_publication_status?
    if published_changed?(from: false, to: true) && !publishable?
      errors.add(:published, "cannot publish #{self.model_name.to_s.downcase} without any published pages")
    end
  end
end

module Publishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where(published: true) }
    scope :tx_resources, -> { published.order(:id) }
  end

  def publishable?
    true
  end

  private

  # only allow changing publication status if we're unpublishing something
  # or if its publishable
  def change_publication_status?
    if published_changed?(from: false, to: true) && !publishable?
      message = "Cannot publish #{self.model_name.to_s.downcase}"
      message += self.class.publishable_error_without
      errors.add(:published, message)
    end
  end
end

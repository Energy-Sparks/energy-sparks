module MailchimpUpdateable
  extend ActiveSupport::Concern

  # TODO do we want CRUD for all?
  # maybe use module ClassMethods and add method to customise
  included do
    before_save :update_mailchimp_timestamp
  end

  private

  def touch_mailchimp_timestamp
    self.mailchimp_fields_changed_at = Time.zone.now
  end

  def touch_mailchimp_timestamp?
    changes.symbolize_keys.keys.any? { |k| self.class.mailchimp_fields.include?(k) }
  end

  def update_mailchimp_timestamp
    touch_mailchimp_timestamp if touch_mailchimp_timestamp?
  end

  module ClassMethods
    def mailchimp_fields
      return [] unless const_defined?(:MAILCHIMP_FIELDS)
      const_get(:MAILCHIMP_FIELDS)
    end
  end
end

module MailchimpUpdateable
  extend ActiveSupport::Concern

  included do
    before_save :update_mailchimp_timestamp
  end

  def touch_mailchimp_timestamp!
    self.update!(mailchimp_fields_changed_at: Time.zone.now)
  end

  private

  def touch_mailchimp_timestamp?
    changes.symbolize_keys.keys.any? { |k| self.class.mailchimp_fields.include?(k) }
  end

  def update_mailchimp_timestamp
    self.mailchimp_fields_changed_at = Time.zone.now if touch_mailchimp_timestamp?
  end

  module ClassMethods
    def mailchimp_fields
      return [] unless const_defined?(:MAILCHIMP_FIELDS)
      const_get(:MAILCHIMP_FIELDS)
    end

    def watch_mailchimp_fields(*fields)
      raise ArgumentError, 'Fields must be symbols' unless fields.all? { |f| f.is_a?(Symbol) }
      const_set(:MAILCHIMP_FIELDS, fields.freeze)
    rescue NameError
      raise 'Cannot modify frozen constant MAILCHIMP_FIELDS'
    end
  end
end

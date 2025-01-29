module MailchimpUpdateable
  extend ActiveSupport::Concern

  # TODO do we want CRUD for all?
  # maybe use module ClassMethods and add method to customise
  included do
    after_update_commit :mailchimp_updates
  end

  private

  def mailchimp_updates
    Mailchimp::UpdateCreator.for(self).record_updates
  end
end

module Mailchimp
  # Mailchimp defines an Audience as a list of Contacts. These contacts are
  # classified into different types (https://mailchimp.com/help/about-your-contacts/)
  # When an Audience is exported there are 4 CSV files, one for each contact type.
  #
  # This service accepts lists of Contacts parsed from a Mailchimp Audience export
  # and provides some support for processing them, e.g. to update the database or
  # export additional information.
  #
  # Code that uses this will be using fields and values as represented in the CSV exports, which
  # will be labelled and structured differently to the API.
  class BaseAudienceExportProcessorService
    # Initialise with lists of hashed fields parsed from Mailchimp export
    def initialize(subscribed:, nonsubscribed:, cleaned:, unsubscribed:)
      @audience = {}
      populate_audience(subscribed: subscribed, nonsubscribed: nonsubscribed, cleaned: cleaned, unsubscribed: unsubscribed)
    end

    private

    # Is this user in Mailchimp? Check each of the 4 contact types
    def in_mailchimp_audience?(user)
      !mailchimp_contact_type(user.email).nil?
    end

    # Identify the contact type for this email address.
    def mailchimp_contact_type(email_address)
      @audience.each do |category, hash|
        return category if hash.key?(email_address)
      end
      nil
    end

    # Lookup the mailchimp contact for an email address, by way of its
    # contact type
    def mailchimp_contact(email_address)
      mailchimp_contact_type = mailchimp_contact_type(email_address)
      return nil if mailchimp_contact_type.nil?
      @audience[mailchimp_contact_type][email_address]
    end

    # Take lists provided in constructor and build an internal hash:
    # contact type => hash (email_address => exported contact)
    def populate_audience(**categories)
      categories.each do |category, list|
        @audience[category] = list_to_hash(list)
      end
    end

    # Convert list of exported contacts to a hash, normalising emails as Mailchimp
    # allows mixed case whereas application is all lower case.
    def list_to_hash(list)
      list.index_by {|c| c[:email_address].downcase}
    end
  end
end

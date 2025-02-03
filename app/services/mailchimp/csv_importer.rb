module Mailchimp
  # Currently only updates the subscriber status, but may do more in future
  class CsvImporter < BaseAudienceExportProcessorService
    def perform
      User.mailchimp_roles.find_each do |user|
        if in_mailchimp_audience?(user)
          mailchimp_contact_type = mailchimp_contact_type(user.email)
          user.update(mailchimp_status: mailchimp_contact_type.to_sym)
        end
      end
    end
  end
end

# frozen_string_literal: true

class ConsentGrantMailerPreview < BasePreview
  def email_consent
    ConsentGrantMailer.with(users: [ConsentGrant.first.user], consent_grant: ConsentGrant.first, locale:).email_consent
  end
end

# frozen_string_literal: true

class ConsentRequestMailerPreview < BasePreview
  def request_consent
    ConsentRequestMailer.with(school: School.first, users: School.first.users, locale:).request_consent
  end
end

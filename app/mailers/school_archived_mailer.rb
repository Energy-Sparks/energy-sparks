# frozen_string_literal: true

class SchoolArchivedMailer < LocaleMailer
  helper :application

  after_action :prevent_delivery_from_test

  def self.archived(school)
    users = school.all_adult_school_users
    with_user_locales(users:, school:) do |mailer|
      mailer.archived.deliver_later
    end
  end

  def archived
    @school = params[:school]
    make_bootstrap_mail(to: params[:users].map(&:email), school: @school)
  end
end

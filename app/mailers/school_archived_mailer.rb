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
    @school_name = params[:school].name
    make_bootstrap_mail(to: params[:users].map(&:email),
                        subject: default_i18n_subject(school_name: @school_name, locale: locale_param))
  end
end

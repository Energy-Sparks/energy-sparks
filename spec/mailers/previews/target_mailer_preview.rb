class TargetMailerPreview < ActionMailer::Preview
  def first_target
    TargetMailer.with(users: School.first.users, school: School.first, locale: locale).first_target
  end

  def first_target_reminder
    TargetMailer.with(users: School.first.users, school: School.first, locale: locale).first_target_reminder
  end

  def review_target
    TargetMailer.with(users: School.first.users, school: SchoolTarget.last.school, locale: locale).review_target
  end

  private

  def locale
    @params['locale'].present? ? @params['locale'] : 'en'
  end
end

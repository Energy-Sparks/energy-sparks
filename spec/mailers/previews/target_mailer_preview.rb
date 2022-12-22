class TargetMailerPreview < ActionMailer::Preview
  def first_target
    TargetMailer.with(to: 'test@blah.com', school: School.first).first_target
  end

  def first_target_reminder
    TargetMailer.with(to: 'test@blah.com', school: School.first).first_target_reminder
  end

  def review_target

    TargetMailer.with(to: 'test@blah.com', school: SchoolTarget.last.school).review_target
  end
end

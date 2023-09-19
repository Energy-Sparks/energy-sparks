class SendReviewSchoolTariffsReminderJob < ApplicationJob
  SEND_ON_MONTH_DAYS = [
    { month: 3, day: 15 },
    { month: 9, day: 15 }
  ].freeze

  queue_as :default

  def priority
    10
  end

  def perform
    return unless send?

    School.all.each do |school|
      EnergyTariffsMailer.with(school_id: school.id).school_admin_review_school_tariffs_reminder.deliver
    end
  end

  def send?
    send_on_month_days_to_dates.include?(Time.zone.today)
  end

  private

  def send_on_month_days_to_dates
    SEND_ON_MONTH_DAYS.map { |send_on| Date.new(Time.zone.today.year, send_on[:month], send_on[:day]) }
  end
end

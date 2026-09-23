# frozen_string_literal: true

namespace :schools do
  task send_expiring_tariff_reminders: :environment do
    def expiring_soon(organisation)
      organisation.energy_tariffs.enabled.current.find { |tariff| tariff.end_date == 30.days.from_now.to_date } &&
        organisation.energy_tariffs.enabled.where(start_date: Date.current..).none?
    end

    begin
      School.active.find_each do |school|
        current_tariff = expiring_soon(school)
        if current_tariff
          EnergyTariffsMailer.reminder_deliver_later_per_locale(school, school.school_admin, current_tariff)
        end
      end

      SchoolGroup.find_each do |school_group|
        current_tariff = expiring_soon(school_group)
        if current_tariff
          EnergyTariffsMailer.reminder_deliver_later_per_locale(school_group, school_group.users.group_admin, current_tariff)
        end
      end
    rescue StandardError => e
      EnergySparks::Log.exception(e, { job: :send_tariff_reminders })
    end
  end
end

  #   School.active.find_each do |school|
  #     # next if EnergyTariffReminder.exists?(school: school, tariff: nil)

  #     current_tariffs = school.energy_tariffs.enabled.current
  #     if current_tariffs.empty? ||
  #        current_tariffs.any? { |tariff| tariff.end_date.nil? && tariff.start_date > 1.year.ago }
  #       school.school_admins.find_each do |user|
  #         EnergyTariffsMailer.reminder_deliver_later_per_locale(user, false).deliver_later
  #       end
  #     end
  #   end

  #   #  unless user.energy_tariff_reminder_sent_at.present?

  #   current_tariff = school.energy_tariffs.enabled.current.find { |tariff| tariff.end_date == 30.days.ago }
  #   if current_tariff
  #     EnergyTariffsMailer.reminder_deliver_later_per_locale(school, school.school_admins, current_tariff)
  #   end




  #     school.school_admins.find_each do |user|
  #       EnergyTariffsMailer.reminder(user).deliver_later
  #     end
  #   end
  # end

  # SchoolGroup.find_each do |school_group|
  #   school_group.energy_tariffs.enabled.current.any?

  #   # User.school_admin

  #   begin
  #     SendReviewSchoolTariffsReminderJob.perform_later
  #   rescue StandardError => e
  #     error_message = "Exception: an email to school group admins to review the information we have about their school group's energy tariffs: #{e.class} #{e.message}"
  #     puts error_message
  #     Rails.logger.error error_message
  #     Rails.logger.error e.backtrace.join("\n")
  #     Rollbar.error(e, job: :send_review_school_tariffs_reminder)
  #   end

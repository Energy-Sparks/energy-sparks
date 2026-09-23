# frozen_string_literal: true

namespace :schools do
  task send_tariff_reminders: :environment do
    def send_tariff_setup_email(organisation)
      current_tariffs = organisation.energy_tariffs.enabled.current
      current_tariffs.empty? ||
        current_tariffs.any? { |tariff| tariff.end_date.nil? && tariff.start_date < 1.year.ago.to_date }
    end

    begin
      School.active.find_each do |school|
        if send_tariff_setup_email(school)
          EnergyTariffsMailer.reminder_deliver_later_per_locale(school, school.school_admin, nil)
        end
      end

      SchoolGroup.find_each do |school_group|
        if send_tariff_setup_email(school_group)
          EnergyTariffsMailer.reminder_deliver_later_per_locale(school_group, school_group.users.group_admin, nil)
        end
      end
    rescue StandardError => e
      EnergySparks::Log.exception(e, { job: :send_tariff_reminders })
    end
  end
end

namespace :schools do
  desc "Sends an email to school group admins to review the information we have about their school group's energy tariffs"
  task send_review_school_tariffs_reminder: :environment do
    School.all.each do |school|
      EnergyTariffsMailer.with(school_id: school.id).school_admin_review_school_tariffs_reminder.deliver
    end
  end
end

namespace :school_groups do
  desc "Sends an email to school group admins to review the information we have about their school group's energy tariffs"
  task send_review_group_tariffs_reminder: :environment do
    SchoolGroup.all.each do |school_group|
      EnergyTariffsMailer.with(school_group_id: school_group.id).group_admin_review_group_tariffs_reminder.deliver
    end
  end
end

namespace :after_party do
  desc 'Deployment task: copy_meter_notes_to_school_issues'
  task copy_meter_notes_to_school_issues: :environment do
    puts "Running deploy task 'copy_meter_notes_to_school_issues'"

    fuel_type_map = {
      electricity: :electricity,
      gas: :gas,
      solar_pv: :solar,
      exported_solar_pv: :solar }

    default_user = User.find_by_email('rebecca.scutt@energysparks.uk')

    Meter.all.each do |meter|
      if meter.notes.present?
        admin_user = meter.school.try(:school_group).try(:default_issues_admin_user) || default_user
        title = "#{meter.fuel_type} meter: #{meter.mpan_mprn}".capitalize
        title += " - #{meter.name}" unless meter.name.blank?
        attrs = {
          issue_type: :issue,
          title: title,
          issueable: meter.school,
          fuel_type: fuel_type_map[meter.fuel_type],
          owned_by: admin_user,
          created_by: admin_user,
          updated_by: admin_user
        }

        Issue.find_or_create_by!(attrs) do |issue|
          issue.description = meter.notes
          issue.meters = [meter]
        end
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

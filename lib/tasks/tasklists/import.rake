namespace :tasklists do
  desc 'Import audit actions and activities and programme activities'
  task import: [:environment] do
    puts "#{Time.zone.now} tasklists import start"

    # Empty out existing tasks. Leave programme intervention types behind, so these can be built up
    puts "Removing audit tasks and programme tasks of type activity type"
    Tasklist::Task.audits.destroy_all
    Tasklist::Task.programme_types.activity_types.destroy_all
    # Tasklist::CompletedTask.all automatically removed

    puts "Importing audit activity_type and intervention_types. Marking them as completed"
    Audit.all.find_each do |audit|
      audit.audit_activity_types.each do |audit_activity_type|
        task = audit.tasklist_tasks.find_or_create_by!(
          task_source: audit_activity_type.activity_type,
          position: audit_activity_type.position,
          notes: audit_activity_type.notes)

        ## latest activity for this activity_type completed since the audit was created
        activity = audit.school.activities.where(
          activity_type: audit_activity_type.activity_type, happened_on: audit.created_at..).order(happened_on: :asc).last

        if activity
          audit.tasklist_completed_tasks.find_or_create_by!(
            tasklist_task: task,
            task_target: activity,
            happened_on: activity.happened_on
          )
        end
      end

      audit.audit_intervention_types.each do |audit_intervention_type|
        task = audit.tasklist_tasks.find_or_create_by!(
          task_source: audit_intervention_type.intervention_type,
          position: audit_intervention_type.position,
          notes: audit_intervention_type.notes)

        ## latest observation for this intervention_type completed since the audit was created
        observation = audit.school.observations.intervention.where(
          intervention_type: audit_intervention_type.intervention_type, at: audit.created_at..).order(at: :asc).last
        if observation
          audit.tasklist_completed_tasks.find_or_create_by!(
            tasklist_task: task,
            task_target: observation,
            happened_on: observation.at
          )
        end
      end
    end

    puts "Importing programme activity_types. Marking them as completed"

    ProgrammeType.all.find_each do |programme_type|
      programme_type.programme_type_activity_types.each do |programme_type_activity_type|
        task = programme_type.tasklist_tasks.find_or_create_by!(
          task_source: programme_type_activity_type.activity_type,
          position: programme_type_activity_type.position,
          notes: nil)

        # Find all records where this activity_type has been completed. Ensures we don't have any rougue entries
        ProgrammeActivity.where(activity_type_id: programme_type_activity_type.activity_type).order(position: :asc).find_each do |programme_activity|
          # only create one record per programme / activity / activity_type
          if programme_activity.activity && programme_activity.programme # there are some activities / programmes referenced that don't exist!
            programme_activity.programme.tasklist_completed_tasks.find_or_create_by(
              tasklist_task: task,
              task_target: programme_activity.activity,
              happened_on: programme_activity.activity.happened_on
            )
          end
        end
      end
    end

    puts "#{Time.zone.now} tasklists import end"
  end
end

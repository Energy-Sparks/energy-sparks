namespace :todos do
  desc 'Import audit actions and activities and programme activities'
  task import: [:environment] do
    puts "#{Time.zone.now} todos import start"

    # Empty out existing todos. Leave programme intervention types behind, so these can be built up
    puts 'Removing audit todos and programme todos of type activity type'
    Todo.audits.destroy_all
    Todo.programme_types.activity_types.destroy_all
    # CompletedTodo.all automatically removed

    puts 'Importing audit activity_type and intervention_types. Marking them as completed'
    Audit.all.find_each do |audit|
      audit.audit_activity_types.each do |audit_activity_type|
        todo = audit.todos.find_or_create_by!(
          task: audit_activity_type.activity_type,
          position: audit_activity_type.position,
          notes: audit_activity_type.notes)

        ## latest activity for this activity_type completed since the audit was created
        activity = audit.school.activities.where(
          activity_type: audit_activity_type.activity_type, happened_on: audit.created_at..).order(happened_on: :asc, id: :asc).last

        if activity
          audit.completed_todos.find_or_create_by!(
            todo: todo,
            recording: activity
          )
        end
      end

      audit.audit_intervention_types.each do |audit_intervention_type|
        todo = audit.todos.find_or_create_by!(
          task: audit_intervention_type.intervention_type,
          position: audit_intervention_type.position,
          notes: audit_intervention_type.notes)

        ## latest observation for this intervention_type completed since the audit was created
        observation = audit.school.observations.intervention.visible.where(
          intervention_type: audit_intervention_type.intervention_type, at: audit.created_at..).order(at: :asc, id: :asc).last
        if observation
          audit.completed_todos.find_or_create_by!(
            todo: todo,
            recording: observation
          )
        end
      end
    end

    puts 'Importing programme activity_types. Marking them as completed'

    ProgrammeType.all.find_each do |programme_type|
      programme_type.programme_type_activity_types.each do |programme_type_activity_type|
        todo = programme_type.todos.find_or_create_by!(
          task: programme_type_activity_type.activity_type,
          position: programme_type_activity_type.position,
          notes: nil)

        ProgrammeActivity.where(programme: programme_type.programmes, activity_type: programme_type_activity_type.activity_type).order(position: :asc).find_each do |programme_activity|
          if programme_activity.activity && programme_activity.programme # there are some activities / programmes referenced that don't exist!
            programme_activity.programme.completed_todos.find_or_create_by(
              todo: todo,
              recording: programme_activity.activity
            )
          else
            puts "Missing activity for: #{programme_activity.inspect}"
          end
        end
      end
    end

    puts "#{Time.zone.now} todos import end"
  end
end

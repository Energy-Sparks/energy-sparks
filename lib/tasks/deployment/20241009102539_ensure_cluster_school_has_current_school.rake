namespace :after_party do
  desc 'Deployment task: ensure_cluster_school_has_current_school'
  task ensure_cluster_school_has_current_school: :environment do
    puts "Running deploy task 'ensure_cluster_school_has_current_school'"

    ActiveRecord::Base.connection.execute('SELECT DISTINCT user_id FROM cluster_schools_users').each do |row|
      user = User.find(row['user_id'])
      user.add_cluster_school(user.school) unless user.school.nil?
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

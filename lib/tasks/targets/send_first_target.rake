namespace :targets do
  desc 'Send email to set first target'
  task send_first_target: [:environment] do
    puts "#{Time.zone.now} Sending first target invite emails"
    Targets::TargetMailerService.new.invite_schools_to_set_first_target
    puts "#{Time.zone.now} Finished sending first target invite emails"
  end
end

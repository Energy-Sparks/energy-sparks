namespace :targets do
  desc 'Send email to set first target'
  task :first_target, :environment do |_t, args|
    Rails.logger.info "Sending first target invite emails"
    Targets::TargetMailerService.new.invite_schools_to_set_first_target
    Rails.logger.info "Finished sending first target invite emails"
  end
end

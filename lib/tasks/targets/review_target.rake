namespace :targets do
  desc 'Send email to set new target'
  task :first_target, :environment do |_t, args|
    Rails.logger.info "Sending set new target emails"
    Targets::TargetMailerService.new.invite_schools_to_review_target
    Rails.logger.info "Finished sending set new target emails"
  end
end

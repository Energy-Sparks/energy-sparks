module MeritHelpers

  def simulate_merit_action(rule, target:, user: nil, has_errors: false, action_value: 'Submit', process: true)
    controller_path = rule.split('#').first
    action_name = rule.split('#').last
    merit_action_hash = {
      user_id:       user.try(:id),
      action_method: action_name,
      action_value:  'Submit',
      had_errors:    has_errors,
      target_model:  controller_path,
      target_id:     target.id,
      target_data:   target
    }
    Merit::Action.create(merit_action_hash)
    process_merit if process
  end

  def process_merit
    Merit::Action.check_unprocessed
  end

end

RSpec.configure do |config|
  config.include MeritHelpers
end

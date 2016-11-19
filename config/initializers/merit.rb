# Use this hook to configure merit parameters
Merit.setup do |config|
  # Check rules on each request or in background
  config.checks_on_each_request = true

  # Define ORM. Could be :active_record (default) and :mongoid
  config.orm = :active_record

  # Add application observers to get notifications when reputation changes.
  # config.add_observer 'MyObserverClassName'

  # Define :user_model_name. This model will be used to grand badge if no
  # `:to` option is given. Default is 'User'.
  config.user_model_name = 'School'

  # Define :current_user_method. Similar to previous option. It will be used
  # to retrieve :user_model_name object if no `:to` option is given. Default
  # is "current_#{user_model_name.downcase}".
  # config.current_user_method = 'current_user'
end


# Create application badges (uses https://github.com/norman/ambry)
# Merit::Badge isn't db persisted, so while it looks odd to specify an id,
# if you don't "Id can't be blank (Ambry::AmbryError)" is thrown
[
  {
    id: 1,
    name: 'enrolled',
    description: 'You enrolled with EnergySparks.',
    custom_fields: {}
  }, {
    id: 2,
    name: 'ten-activities',
    description: 'You\'ve recorded 10 activities!',
    custom_fields: {}
  }, {
    id: 3,
    name: 'weekly-participiation',
    description: 'You\'ve logged in every day this week!',
    custom_fields: {}
  }, {
    id: 4,
    name: 'solar-panels',
    description: 'Solar panels have been installed at your school.',
    custom_fields: {}
  }, {
    id: 5,
    name: 'eco-enrolled',
    description: 'Your school enrolled in the eco-school programme.',
    custom_fields: {}
  }, {
    id: 6,
    name: 'eco-status-green',
    description: 'Your school reached the top level in the eco-school programme!',
    custom_fields: {}
  }, {
    id: 7,
    name: 'number-one',
    description: 'You\'re number one!',
    custom_fields: {}
  }, {
    id: 8,
    name: 'activity-per-week',
    description: 'You recorded an activity every week last term.',
    custom_fields: {}
  }, {
    id: 9,
    name: 'weekly-energy-reduction',
    description: 'You reduced your total energy usage last week.',
    custom_fields: {}
  }, {
    id: 10,
    name: 'electricity-reduction-10',
    description: 'You reduced your electricity usage by 10%.',
    custom_fields: {}
  }, {
    id: 11,
    name: 'electricity-reduction-20',
    description: 'You reduced your electricity usage by 20%.',
    custom_fields: {}
  }, {
    id: 12,
    name: 'gas-reduction-10',
    description: 'You reduced your gas usage by 10%.',
    custom_fields: {}
  }, {
    id: 13,
    name: 'gas-reduction-20',
    description: 'You reduced your gas usage by 20%.',
    custom_fields: {}
  }
].each { |attrs| ::Merit::Badge.create! attrs }

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
    name: 'registered',
    description: 'You registered with EnergySparks.',
    custom_fields: {image: 'badges/star.png'}
  }, {
    id: 2,
    name: 'ten-activities',
    description: 'You\'ve recorded 10 activities!',
    custom_fields: {image: 'badges/star.png'}
  }, {
    id: 3,
    name: 'weekly-participiation',
    description: 'You\'ve logged in every day this week!',
    custom_fields: {image: 'badges/star.png'}
  }, {
    id: 4,
    name: 'solar-panels',
    description: 'Solar panels have been installed at your school.',
    custom_fields: {image: 'badges/star.png'}
  }, {
    id: 5,
    name: 'eco-programme',
    description: 'Your school enrolled in the eco-school programme.',
    custom_fields: {image: 'badges/star.png'}
  }, {
    id: 6,
    name: 'energy-reduction',
    description: 'You reduced your energy usage last week.',
    custom_fields: {image: 'badges/star.png'}
  }
].each { |attrs| ::Merit::Badge.create! attrs }

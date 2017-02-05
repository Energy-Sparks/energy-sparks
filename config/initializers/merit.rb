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
    description: 'Enrol with EnergySparks',
    custom_fields: {
        image: 'badges/bulb',
        title: 'Welcome'
    }
  }, {
    id: 2,
    name: 'ten-activities',
    description: 'Record 10 activities',
    custom_fields: {
        image: 'badges/paper',
        title: 'Note Taker'
    }
  }, {
    id: 16,
    name: 'eco-status-green',
    description: 'Achieve green flag status',
    custom_fields: {
        image: 'badges/bulb',
        title: 'Green Flag Award'
    }
  }, {
    id: 14,
    name: 'eco-status-bronze',
    description: 'Receive a bronze award',
    custom_fields: {
        image: 'badges/bulb',
        title: 'Bronze Award'
    }
  }, {
    id: 15,
    name: 'eco-status-silver',
    description: 'Receive a silver award',
    custom_fields: {
        image: 'badges/bulb',
        title: 'Silver Award'
    }
  }
].each { |attrs| ::Merit::Badge.create! attrs }

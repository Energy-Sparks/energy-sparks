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
  },
  {
      id: 2,
      name: 'ten-activities',
      description: 'Record 10 activities',
      custom_fields: {
          image: 'badges/paper',
          title: 'Note Taker'
      }
  },
  {
      id: 3,
      name: 'first-activity',
      description: 'Record your first activity',
      custom_fields: {
          image: 'badges/paper',
          title: 'Getting started'
      }
  },
  {
      id: 4,
      name: 'all-categories',
      description: 'Record one activity in each category',
      custom_fields: {
          image: 'badges/paper',
          title: 'Action Plan'
      }
  },
  {
      id: 5,
      name: 'all-activities',
      description: 'Record every type of activity',
      custom_fields: {
          image: 'badges/paper',
          title: 'Active School'
      }
  },
  {
      id: 6,
      name: 'evidence',
      description: 'Add a link to a web page, photo or video',
      custom_fields: {
          image: 'badges/paper',
          title: 'Evidence'
      }
  },
  {
      id: 7,
      name: 'first-steps',
      description: 'Sign in for the first time',
      custom_fields: {
          image: 'badges/bulb',
          title: 'First Steps'
      }
  },
  {
      id: 16,
      name: 'eco-status-green',
      description: 'Achieve Ecoschool green flag status',
      custom_fields: {
          image: 'badges/green_award',
          title: 'Green Flag Award'
      }
  },
  {
      id: 14,
      name: 'eco-status-bronze',
      description: 'Receive an Ecoschool bronze award',
      custom_fields: {
          image: 'badges/bronze_award',
          title: 'Bronze Award'
      }
  },
  {
      id: 15,
      name: 'eco-status-silver',
      description: 'Receive an Ecoschool silver award',
      custom_fields: {
          image: 'badges/silver_award',
          title: 'Silver Award'
      }
  }
].each { |attrs| ::Merit::Badge.create! attrs }

# Use this hook to configure merit parameters
Merit.setup do |config|
  # Check rules on each request or in background
  config.checks_on_each_request = true

  # Define ORM. Could be :active_record (default) and :mongoid
  config.orm = :active_record

  # Add application observers to get notifications when reputation changes.
  # config.add_observer 'MyObserverClassName'

  # Define :user_model_name. This model will be used to grant badge if no
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
        name: 'welcome',
        description: 'Enrol with EnergySparks and then sign in for the first time',
        custom_fields: {
            image: 'badges/bulb',
            title: 'Welcome'
        }
    },
    {
        id: 2,
        name: 'player',
        description: 'Score some points and then explore the score board',
        custom_fields: {
            image: 'badges/bulb',
            title: 'Player'
        }
    },
    {
        id: 3,
        name: 'data-scientist',
        description: 'Explore the graphs, then record an activity',
        custom_fields: {
            image: 'badges/bulb',
            title: 'Data Scientist'
        }
    },
    {
        id: 4,
        name: 'competitor',
        description: 'Take part in an Energy Sparks competition',
        custom_fields: {
            image: 'badges/bulb',
            title: 'Competitor'
        }
    },
    {
        id: 5,
        name: 'winner',
        description: 'Win an Energy Sparks competition',
        custom_fields: {
            image: 'badges/bulb',
            title: 'Winner!'
        }
    },
    {
        id: 6,
        name: 'beginner',
        description: 'Record your first activity',
        custom_fields: {
            image: 'badges/bulb',
            title: 'Beginner'
        }
    },
    {
        id: 7,
        name: 'evidence',
        description: 'Add a link to a web page, photo or video',
        custom_fields: {
            image: 'badges/paper',
            title: 'Evidence'
        }
    },
    {
        id: 8,
        name: 'reporter-20',
        description: 'Record 20 activities',
        custom_fields: {
            image: 'badges/paper',
            title: 'Reporter (20)'
        }
    },
    {
        id: 9,
        name: 'reporter-50',
        description: 'Record 50 activities',
        custom_fields: {
            image: 'badges/paper',
            title: 'Reporter (50)'
        }
    },
    {
        id: 10,
        name: 'reporter-100',
        description: 'Record 100 activities',
        custom_fields: {
            image: 'badges/paper',
            title: 'Reporter (100)'
        }
    },
    {
        id: 11,
        name: 'investigator',
        description: 'Record 5 different types of activity in the "Investigating energy usage" category',
        custom_fields: {
            image: 'badges/paper',
            title: 'Investigator'
        }
    },
    {
        id: 12,
        name: 'learner',
        description: 'Record 5 different types of activity in the "Learning" category',
        custom_fields: {
            image: 'badges/paper',
            title: 'Learner'
        }
    },
    {
        id: 13,
        name: 'communicator',
        description: 'Record 5 different types of activity in the "Spreading the message" category',
        custom_fields: {
            image: 'badges/paper',
            title: 'Communicator'
        }
    },
    {
        id: 14,
        name: 'energy-saver',
        description: 'Record 5 different types of activity in the "Taking action around the school" category',
        custom_fields: {
            image: 'badges/paper',
            title: 'Energy Saver'
        }
    },
    {
        id: 15,
        name: 'teamwork',
        description: 'Record 5 different types of activity in the "Whole-school activities" category',
        custom_fields: {
            image: 'badges/paper',
            title: 'Teamwork'
        }
    },
    {
        id: 16,
        name: 'explorer',
        description: 'Record one activity in each category',
        custom_fields: {
            image: 'badges/paper',
            title: 'Explorer'
        }
    },
    {
        id: 17,
        name: 'autumn-term',
        description: 'At least one activity per week',
        custom_fields: {
            image: 'badges/paper',
            title: 'Autumn Term'
        }
    },
    {
        id: 18,
        name: 'spring-term',
        description: 'At least one activity per week',
        custom_fields: {
            image: 'badges/paper',
            title: 'Spring Term'
        }
    },
    {
        id: 19,
        name: 'summer-term',
        description: 'At least one activity per week',
        custom_fields: {
            image: 'badges/paper',
            title: 'Summer Term'
        }
    },
    {
        id: 20,
        name: 'graduate',
        description: 'Collect all the term badges',
        custom_fields: {
            image: 'badges/paper',
            title: 'Graduate'
        }
    }
].each { |attrs| ::Merit::Badge.create! attrs }

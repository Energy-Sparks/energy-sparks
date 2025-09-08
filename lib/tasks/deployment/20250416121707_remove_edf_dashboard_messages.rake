namespace :after_party do
  desc 'Deployment task: remove_edf_dashboard_messages'
  task remove_edf_dashboard_messages: :environment do
    puts "Running deploy task 'remove_edf_dashboard_messages'"


    schools = ["woolavington-village-primary-school",
               "priors-hall",
               "buxton-junior-school",
               "westover-green-community-school-and-autism-centre",
               "albany-junior-school",
               "bobby-moore-academy-secondary",
               "st-peter-s-cofe-primary-and-nursery-school-gringley-on-the-h",
               "james-gillespie-s-high-school",
               "harris-academy-and-primary-academy-chafford-hundred",
               "harris-primary-academy-purley-way",
               "harris-academy-tottenham",
               "st-thomas-of-aquin-s-high-school",
               "harris-primary-academy-merton",
               "harris-invictus-academy-croydon",
               "john-port-spencer-academy",
               "mary-elton-primary-school",
               "harris-academy-beckenham",
               "harris-junior-academy-carshalton",
               "northgate-primary-school",
               "harris-academy-clapham",
               "harris-garrard-academy",
               "harris-primary-academy-haling-park",
               "harris-academy-purley",
               "harris-academy-st-john-s-wood",
               "lliswerry-primary-school",
               "harris-academy-bermondsey",
               "harris-academy-orpington",
               "harris-academy-falconwood",
               "harris-primary-academy-shortlands",
               "harris-girls-academy-bromley",
               "harris-primary-academy-peckham-park",
               "wyndham-spencer-academy",
               "harris-academy-greenwich",
               "harris-academy-wimbledon",
               "exeter-school",
               "harris-academy-south-norwood-beulah-hill-campus",
               "woodnewton-school",
               "harris-academy-merton",
               "ashwood-spencer-academy",
               "heanor-gate-spencer-academy",
               "harris-academy-rainham",
               "george-spencer-academy",
               "millside-spencer-academy",
               "harris-academy-peckham",
               "harris-academy-south-norwood-clocktower-campus",
               "harris-academy-battersea",
               "derby-moor-spencer-academy",
               "harris-academy-riverside",
               "harris-westminster-sixth-form",
               "arnold-hill-spencer-academy",
               "stanton-vale-school",
               "harris-professional-skills-sixth-form",
               "harris-boys-academy-east-dulwich",
               "harris-academy-chobham",
               "harris-academy-sutton",
               "glenbrook-spencer-academy",
               "robin-hood-junior-school",
               "harris-city-academy-crystal-palace",
               "harris-primary-academy-beckenham-green"]

    message = "Your school's recent electricity data is currently missing. This has been raised with your electricity supplier to investigate and once the data is available, it will be added to your school's dashboard."

    schools.each do |slug|
      school = School.find_by_slug(slug)
      next unless school
      DashboardMessage.delete_or_remove_message!(school, message)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

namespace :after_party do
  desc 'Deployment task: perse_dashboard_messages'
  task perse_dashboard_messages: :environment do
    puts "Running deploy task 'perse_dashboard_messages'"

    schools = ["shacklewell-primary-school",
               "the-hythe-community-primary-school",
               "perryfields-academy",
               "all-saints-catholic-high-school",
               "coten-end-primary-school",
               "friesland-school",
               "botley-school",
               "heritage-high-school",
               "manor-academy",
               "sparkenhoe-community-primary-school",
               "selston-high-school",
               "wilsthorpe-school",
               "forest-school",
               "woodmansterne-school-and-sixth-form",
               "springfield-community-primary-school",
               "ryburn-valley-high-school",
               "wreake-valley-academy",
               "wyvern-primary-school",
               "healing-primary-academy",
               "ellesmere-college-aylestone-meadows-campus",
               "paxton-primary-school",
               "braunstone-frith-primary-academy",
               "st-nicholas-priory-school",
               "thomas-fairchild-community-school",
               "alp-sittingbourne",
               "heath-primary-school",
               "ermine-primary-academy",
               "ashfield-school",
               "river-academy",
               "the-st-marylebone-school-64-marylebone-high-street",
               "medway-community-primary-school",
               "healing-science-academy",
               "dartford-science-and-technology-college",
               "moat-community-college",
               "salisbury-cathedral-school",
               "sheringham-woodfields-school",
               "spinney-hill-primary-school",
               "sandfield-close-primary-school",
               "taylor-road-primary-school",
               "braunton-academy",
               "duke-of-lancaster-academy",
               "the-ashley-school",
               "whitefriars-school",
               "st-mary-s-church-of-england-academy-mildenhall",
               "the-roundhill-academy",
               "the-judd-school",
               "ellesmere-college-knighton-fields-campus",
               "comberton-village-college",
               "linden-primary-school",
               "frederick-gent-school",
               "john-grant-school",
               "great-wilbraham-primary",
               "barley-croft-primary-school",
               "cokethorpe-school",
               "lillington-primary-school",
               "st-giles-academy",
               "oasis-academy-daventry-road",
               "stokes-wood-primary-school",
               "brighton-aldridge-community-academy",
               "montrose-school",
               "new-college-leicester"]

    message = "Your school's recent electricity data is currently missing. Your data provider is experiencing some issues which are causing these delays. Once the data is available again, it will be added to your school's dashboard."

    schools.each do |slug|
      school = School.find_by_slug(slug)
      next unless school
      DashboardMessage.add_or_insert_message!(school, message)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

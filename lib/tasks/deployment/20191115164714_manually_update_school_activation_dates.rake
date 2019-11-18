namespace :after_party do
  desc 'Deployment task: manually_update_school_activation_dates'
  task manually_update_school_activation_dates: :environment do
    puts "Running deploy task 'manually_update_school_activation_dates'"

    {
      Date.new(2017, 9, 1) => [
        'Bishop Sutton Primary School',
        'Castle Primary School',
        'Freshford Church School',
        'Paulton Junior School',
        'Pensford Primary School',
        'Roundhill Primary School',
        'Saltford C of E Primary School',
        'Stanton Drew Primary School',
        'Twerton Infant School',
        'Westfield Primary School',
        'St Johns Catholic Primary School Bath'
      ],
      Date.new(2019, 11, 12) => ['Marksbury C of E Primary School'],
      Date.new(2018, 7, 1) => ['St Marks C of E School'],
      Date.new(2019, 12, 1) => ['St Saviours Junior Church School']
    }.each do |date, schools|
      schools.each do |school|
        School.find_by!(name: school).observations.event.update_all(at: date)
      end
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

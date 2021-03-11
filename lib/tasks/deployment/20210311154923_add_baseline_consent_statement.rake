namespace :after_party do
  desc 'Deployment task: Add first consent statement'
  task add_baseline_consent_statement: :environment do
    puts "Running deploy task 'default_consent_statement'"

    content = <<-EOL
    <p>I would like to enrol our school in the Energy Sparks service to allow the school to better monitor our energy usage.</p>
    <p>I understand that in order for this to happen, our energy usage data will need to be published under an open licence to Energy Sparks. This includes both ongoing and historical data.</p>
    <p>I understand that publishing the data under an open licence will allow it to be accessed, used and shared by anyone, including the Energy Sparks team.</p>
    <p>I would like to give permission to begin publishing our energy usage data at the earliest opportunity.</p>
    <p>I also give permission for Energy Sparks to obtain our energy tariff information from our energy contract manager or supplier so as to provide more accurate cost and savings estimates through the Energy Sparks tool.</p>
    <p>I understand that our school has the right to withdraw consent to our data being published to Energy Sparks at anytime. I can withdraw consent by emailing hello@energysparks.uk. We will then remove your ongoing and historical data from the Energy Sparks site.</p>
    EOL

    if ConsentStatement.any?
      puts "A ConsentStatement already exists, skipping task"
    else
      ConsentStatement.create!(
        title: "Baseline Consent Statement",
        content: content,
        current: true
      )
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

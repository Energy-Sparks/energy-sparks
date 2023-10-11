namespace :intervention_types do
  desc 'Export intervention types'
  task export: [:environment] do
    puts "#{Time.zone.now} Generating export"
    CSV.open('intervention_types.csv', 'w') do |csv|
      csv << %w[ID
                Name
                Summary
                Score
                Active
                Custom]
      InterventionType.all.each do |intervention_type|
        csv << [
          intervention_type.id,
          intervention_type.name,
          intervention_type.summary,
          intervention_type.score,
          intervention_type.active,
          intervention_type.custom
        ]
      end
    end
    puts "#{Time.zone.now} Finished export"
  end
end

namespace :school do
  desc 'Update establishment_id column for all active Schools in England and Wales'
  task :match_establishments, [:path] => :environment do |_t, _args|
    stats = { perfect: 0, la_plus_en: 0, unmatched: 0 }
    update = {}

    School.active.where(country: [:england, :wales]).find_each do |sch|
      update[sch.id] = { establishment: Lists::Establishment.find_establishment_for_school(sch, stats) }
    end

    puts "Updating with #{update.count} entries..."
    School.update(update.keys, update.values)
    puts "Perfect matches: #{stats[:perfect]}\nLA+EN matches: #{stats[:la_plus_en]}\nUnmatched: #{stats[:unmatched]}\n"
  end
end

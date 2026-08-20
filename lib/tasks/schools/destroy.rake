# frozen_string_literal: true

namespace :school do
  desc 'Delete archived/removed schools'
  task destroy: :environment do
    puts "#{DateTime.now.utc} Destroy schools start"
    Schools::Destroyer.new.perform!
    puts "#{DateTime.now.utc} Destroy schools end"
  end
end

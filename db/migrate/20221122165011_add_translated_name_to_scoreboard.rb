class AddTranslatedNameToScoreboard < ActiveRecord::Migration[6.0]
  def change
    Scoreboard.all.each do |scoreboard|
      scoreboard.update(name: scoreboard[:name])
    end
  end
end

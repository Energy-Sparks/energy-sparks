class AddTimestampsToProgrammeType < ActiveRecord::Migration[6.0]
  def change
    #set the default to be just before when we did the first transifex sync of this content
    add_timestamps(:programme_types, null: false, default: DateTime.new(2022,07,06,12,00))
  end
end

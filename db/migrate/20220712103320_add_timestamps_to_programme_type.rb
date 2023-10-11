class AddTimestampsToProgrammeType < ActiveRecord::Migration[6.0]
  def change
    # set the default to be just before when we did the first transifex sync of this content
    add_timestamps(:programme_types, null: false, default: DateTime.new(2022, 0o7, 0o6, 12, 0o0))
  end
end

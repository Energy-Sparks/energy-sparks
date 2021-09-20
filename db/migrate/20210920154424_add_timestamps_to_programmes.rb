class AddTimestampsToProgrammes < ActiveRecord::Migration[6.0]
  def change
    add_timestamps :programmes, null: false, default: -> { 'NOW()' }
  end
end

class CreateRecentChangeInBaseloads < ActiveRecord::Migration[6.1]
  def change
    create_view :recent_change_in_baseloads
  end
end

class AddCalendarAreaLinkToScoreboards < ActiveRecord::Migration[6.0]
  def change
    add_reference :scoreboards, :calendar_area, foreign_key: {on_delete: :restrict}
  end
end

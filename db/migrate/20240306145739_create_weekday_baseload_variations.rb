class CreateWeekdayBaseloadVariations < ActiveRecord::Migration[6.1]
  def change
    create_view :weekday_baseload_variations
  end
end

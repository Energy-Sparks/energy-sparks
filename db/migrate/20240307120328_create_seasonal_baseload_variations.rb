class CreateSeasonalBaseloadVariations < ActiveRecord::Migration[6.1]
  def change
    create_view :seasonal_baseload_variations
  end
end

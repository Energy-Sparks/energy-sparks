class CreateHolidayAndTerms < ActiveRecord::Migration[7.0]
  def change
    create_view :holiday_and_terms
  end
end

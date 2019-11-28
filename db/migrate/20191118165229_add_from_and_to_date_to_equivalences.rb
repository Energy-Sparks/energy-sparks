class AddFromAndToDateToEquivalences < ActiveRecord::Migration[6.0]
  def change
    add_column :equivalences, :from_date, :date
    add_column :equivalences, :to_date, :date
  end
end

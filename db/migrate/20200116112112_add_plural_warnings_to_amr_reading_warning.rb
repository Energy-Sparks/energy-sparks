class AddPluralWarningsToAmrReadingWarning < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_reading_warnings, :warning_types, :integer, array: true
  end
end

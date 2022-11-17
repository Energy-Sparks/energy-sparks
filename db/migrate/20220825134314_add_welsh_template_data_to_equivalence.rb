class AddWelshTemplateDataToEquivalence < ActiveRecord::Migration[6.0]
  def change
    add_column :equivalences, :data_cy, :json, default: {}
  end
end

class CreateAlertTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :alert_types do |t|
      t.integer   :category # enum
      t.integer   :sub_category # enum
      t.integer   :frequency # enum
      t.text      :title
      t.text      :description
      t.text      :analysis
    end
  end
end

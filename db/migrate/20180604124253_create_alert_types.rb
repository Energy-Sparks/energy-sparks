class CreateAlertTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :alert_types do |t|
      t.integer   :category #enum
      t.integer   :sub_category #enum
      t.text      :title
      t.boolean   :short_term
      t.boolean   :long_term
      t.text      :sample_message
      t.text      :analysis_description
      t.integer   :daily_frequency
    end
  end
end

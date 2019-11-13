class CreateAlertGenerationRun < ActiveRecord::Migration[6.0]
  def change
    create_table :alert_generation_runs do |t|
      t.references :school
      t.timestamps
    end
  end
end

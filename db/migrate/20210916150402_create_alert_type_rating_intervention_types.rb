class CreateAlertTypeRatingInterventionTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :alert_type_rating_intervention_types do |t|
      t.belongs_to :intervention_type, null: false, foreign_key: true, index: { name: :idx_alert_type_rating_intervention_types_on_int_type_id }
      t.belongs_to :alert_type_rating, null: false, foreign_key: true, index: { name: :idx_alert_type_rating_intervention_types_on_alrt_type_id }
      t.integer :position

      t.timestamps
    end
  end
end

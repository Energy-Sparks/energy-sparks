class CreateAdvicePageInterventionTypeJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_table :advice_page_intervention_types do |t|
      t.belongs_to :advice_page
      t.belongs_to :intervention_type
      t.integer :position
    end
  end
end

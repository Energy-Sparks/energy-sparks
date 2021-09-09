class ReviseInterventionType < ActiveRecord::Migration[6.0]
  def change
    add_column :intervention_types, :active, :boolean, default: true
    add_column :intervention_types, :summary, :string
  end
end

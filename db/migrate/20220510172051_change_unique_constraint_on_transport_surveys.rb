class ChangeUniqueConstraintOnTransportSurveys < ActiveRecord::Migration[6.0]
  def change
    remove_index :transport_surveys, :run_on
    add_index :transport_surveys, %i[school_id run_on], unique: true
  end
end

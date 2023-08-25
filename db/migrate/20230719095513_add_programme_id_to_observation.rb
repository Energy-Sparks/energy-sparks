class AddProgrammeIdToObservation < ActiveRecord::Migration[6.0]
  def change
    add_reference :observations, :programme, foreign_key: { on_delete: :cascade }
  end
end

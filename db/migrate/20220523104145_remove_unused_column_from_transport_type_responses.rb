class RemoveUnusedColumnFromTransportTypeResponses < ActiveRecord::Migration[6.0]
  def change
    remove_column :transport_survey_responses, :integer, :integer
  end
end

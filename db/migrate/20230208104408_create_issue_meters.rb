class CreateIssueMeters < ActiveRecord::Migration[6.0]
  def change
    create_table :issue_meters do |t|
      t.references :issue, foreign_key: true
      t.references :meter, foreign_key: true
      t.timestamps
    end
  end
end

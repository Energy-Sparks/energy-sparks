class AddReviewDateToIssues < ActiveRecord::Migration[7.2]
  def change
    add_column :issues, :review_date, :date
  end
end

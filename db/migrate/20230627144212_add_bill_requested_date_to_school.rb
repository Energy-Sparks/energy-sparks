class AddBillRequestedDateToSchool < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :bill_requested_at, :datetime
  end
end

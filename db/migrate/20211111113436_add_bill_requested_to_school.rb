class AddBillRequestedToSchool < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :bill_requested, :boolean, default: false
  end
end

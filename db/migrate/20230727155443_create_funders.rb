class CreateFunders < ActiveRecord::Migration[6.0]
  def change
    create_table :funders do |t|
      t.string :name, null: false
    end
    add_column :schools, :funder_id, :bigint
  end
end

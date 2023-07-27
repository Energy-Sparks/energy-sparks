class CreateFunders < ActiveRecord::Migration[6.0]
  def change
    create_table :funders do |t|
      t.string :name, null: false
    end
    add_reference :schools, :funder
  end
end

class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.text      :title
      t.text      :description
      t.integer   :parent_group_id, index: true
    end
  end
end

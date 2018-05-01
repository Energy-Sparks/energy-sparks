class CreateSashes < ActiveRecord::Migration[5.0]
  def change
    create_table :sashes do |t|
      t.timestamps
    end
  end
end

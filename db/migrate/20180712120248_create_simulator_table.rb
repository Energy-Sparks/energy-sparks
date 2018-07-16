class CreateSimulatorTable < ActiveRecord::Migration[5.2]
  def change
    create_table :simulators do |t|
      t.text        :title
      t.text        :notes
      t.references  :school,     foreign_key: true
      t.references  :user,       foreign_key: true
      t.text        :configuration
      t.timestamps
    end
  end
end

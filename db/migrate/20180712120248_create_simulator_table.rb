class CreateSimulatorTable < ActiveRecord::Migration[5.2]
  def change
    create_table :simulators do |t|
      t.references  :school,     foreign_key: true
      t.references  :user,       foreign_key: true
      t.json        :configuration
    end
  end
end

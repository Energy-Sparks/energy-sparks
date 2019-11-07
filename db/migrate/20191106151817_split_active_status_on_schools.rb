class SplitActiveStatusOnSchools < ActiveRecord::Migration[6.0]
  def change

    add_column :schools, :visible, :boolean, default: false
    add_column :schools, :process_data, :boolean, default: false

    reversible do |dir|
      dir.up do
        connection.execute("UPDATE schools SET visible = 't', process_data = 't' WHERE active IS TRUE")
      end
      dir.down do
        connection.execute("UPDATE schools SET active = 't' WHERE process_data IS TRUE AND visible IS TRUE")
      end
    end

    remove_column :schools, :active, :boolean, default: false
  end
end

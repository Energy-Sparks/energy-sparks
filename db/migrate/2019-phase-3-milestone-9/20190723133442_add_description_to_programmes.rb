class AddDescriptionToProgrammes < ActiveRecord::Migration[6.0]
  def change
    add_column :programmes, :description, :text
    reversible do |dir|
      dir.up do
        connection.execute('UPDATE programmes SET description = programme_types.description FROM programme_types WHERE programmes.programme_type_id = programme_types.id')
      end
    end
  end
end

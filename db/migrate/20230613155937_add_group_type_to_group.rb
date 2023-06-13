class AddGroupTypeToGroup < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TYPE group_types AS ENUM ('general', 'local_authority', 'multi_academy_trust');
    SQL
    add_column :school_groups, :group_type, :group_types, default: 'general'
  end
  def down
    remove_column :school_groups, :group_type
    execute <<-SQL
      DROP TYPE group_types;
    SQL
  end
end

class AddDataSharingEnumToSchool < ActiveRecord::Migration[7.0]
  def up
    create_enum :data_sharing, ["public", "within_group", "private"]
    add_column :schools, :data_sharing, :enum, enum_type: :data_sharing, default: "public", null: false
  end

  def down
    remove_column :schools, :data_sharing

    # Rails 7.0
    execute <<-SQL
      DROP TYPE data_sharing;
    SQL

    # drop_enum :data_sharing, Rails 7.1 only?
  end
end

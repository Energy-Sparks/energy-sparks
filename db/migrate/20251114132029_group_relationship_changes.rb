class GroupRelationshipChanges < ActiveRecord::Migration[7.2]
  def change
    # To allow matching against DfE data
    add_column :school_groups, :dfe_code, :string

    add_reference :school_onboardings, :diocese, foreign_key: { to_table: :school_groups }, index: true
    add_reference :school_onboardings, :local_authority_area, foreign_key: { to_table: :school_groups }, index: true

    # Separate out the diocese role
    add_enum_value :school_grouping_role, 'diocese'
  end
end

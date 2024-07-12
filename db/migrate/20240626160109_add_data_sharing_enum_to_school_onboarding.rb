class AddDataSharingEnumToSchoolOnboarding < ActiveRecord::Migration[7.0]
  def up
    add_column :school_onboardings, :data_sharing, :enum, enum_type: :data_sharing, default: "public", null: false
  end

  def down
    remove_column :school_onboardings, :data_sharing
  end
end

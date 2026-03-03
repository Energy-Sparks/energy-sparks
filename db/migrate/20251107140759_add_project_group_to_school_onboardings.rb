class AddProjectGroupToSchoolOnboardings < ActiveRecord::Migration[7.2]
  def change
    add_reference :school_onboardings, :project_group, foreign_key: { to_table: :school_groups }, index: true
  end
end

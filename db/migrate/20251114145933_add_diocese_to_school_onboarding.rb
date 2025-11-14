class AddDioceseToSchoolOnboarding < ActiveRecord::Migration[7.2]
  def change
    add_reference :school_onboardings, :diocese, foreign_key: { to_table: :school_groups }, index: true
  end
end

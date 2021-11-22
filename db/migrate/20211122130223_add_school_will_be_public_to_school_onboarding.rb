class AddSchoolWillBePublicToSchoolOnboarding < ActiveRecord::Migration[6.0]
  def change
    add_column :school_onboardings, :school_will_be_public, :boolean, default: true
  end
end

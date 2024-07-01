class AddSchoolOnboardingFunder < ActiveRecord::Migration[7.0]
  def change
    add_reference :school_onboardings, :funder
  end
end

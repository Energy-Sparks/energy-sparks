class AddSubscribeUsersToNewslettersToSchoolOnboarding < ActiveRecord::Migration[6.0]
  def change
    add_column :school_onboardings, :subscribe_users_to_newsletter, :bigint, array: true, null: false, default: []
  end
end

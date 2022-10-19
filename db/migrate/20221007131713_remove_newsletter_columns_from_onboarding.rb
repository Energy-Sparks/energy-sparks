class RemoveNewsletterColumnsFromOnboarding < ActiveRecord::Migration[6.0]
  def change
    remove_column :school_onboardings, :subscribe_to_newsletter, :boolean, default: true
    remove_column :school_onboardings, :subscribe_users_to_newsletter, :bigint, array: true, null: false, default: []
  end
end

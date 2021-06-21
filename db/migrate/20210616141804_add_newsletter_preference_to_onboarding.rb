class AddNewsletterPreferenceToOnboarding < ActiveRecord::Migration[6.0]
  def change
    add_column :school_onboardings,       :subscribe_to_newsletter, :boolean, default: true
  end
end

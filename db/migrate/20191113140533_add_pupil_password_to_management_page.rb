class AddPupilPasswordToManagementPage < ActiveRecord::Migration[6.0]
  def change
    add_column :site_settings, :message_for_no_pupil_accounts, :boolean, default: true
  end
end

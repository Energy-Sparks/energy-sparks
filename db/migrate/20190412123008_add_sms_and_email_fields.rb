class AddSmsAndEmailFields < ActiveRecord::Migration[5.2]
  def change
    add_column :alert_type_ratings, :sms_active, :boolean, default: false
    add_column :alert_type_ratings, :email_active, :boolean, default: false
    add_column :alert_type_ratings, :find_out_more_active, :boolean, default: false

    add_column :alert_type_rating_content_versions, :sms_content, :string
    add_column :alert_type_rating_content_versions, :email_title, :string
    add_column :alert_type_rating_content_versions, :email_content, :text

    reversible do |dir|
      dir.up do
        connection.execute("UPDATE alert_type_ratings SET find_out_more_active = 't'")
      end
    end
  end
end

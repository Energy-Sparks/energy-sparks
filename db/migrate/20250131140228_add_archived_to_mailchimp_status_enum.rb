class AddArchivedToMailchimpStatusEnum < ActiveRecord::Migration[7.1]
  def change
    add_enum_value :mailchimp_status, 'archived'
  end
end

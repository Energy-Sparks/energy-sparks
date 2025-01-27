# == Schema Information
#
# Table name: mailchimp_updates
#
#  created_at   :datetime         not null
#  id           :bigint(8)        not null, primary key
#  processed_at :date
#  status       :enum
#  status_note  :text
#  update_type  :enum
#  updated_at   :datetime         not null
#  user_id      :bigint(8)        not null
#
# Indexes
#
#  index_mailchimp_updates_on_user_id                             (user_id)
#  index_mailchimp_updates_on_user_id_and_status_and_update_type  (user_id,status,update_type) UNIQUE
#
module Mailchimp
  class Update < ApplicationRecord
    self.table_name = 'mailchimp_updates'

    belongs_to :user

    enum :status, { pending: 'pending', processed: 'processed' }
    enum :update_type, {
      update_contact: 'update_contact',
      archive_contact: 'archive_contact',
      update_contact_tags: 'update_contact_tags'
    }

    validates :user, :status, :update_type, presence: true
    validates_uniqueness_of :user, scope: :update_type
  end
end

# == Schema Information
#
# Table name: commercial_contract_contacts
#
#  comments             :text
#  contact_type         :enum             not null
#  contract_holder_id   :bigint(8)        not null
#  contract_holder_type :string           not null
#  created_at           :datetime         not null
#  created_by_id        :bigint(8)
#  email                :string           not null
#  id                   :bigint(8)        not null, primary key
#  name                 :string           not null
#  updated_at           :datetime         not null
#  updated_by_id        :bigint(8)
#  user_id              :bigint(8)
#
# Indexes
#
#  index_commercial_contract_contacts_on_contract_holder  (contract_holder_type,contract_holder_id)
#  index_commercial_contract_contacts_on_created_by_id    (created_by_id)
#  index_commercial_contract_contacts_on_updated_by_id    (updated_by_id)
#  index_commercial_contract_contacts_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (updated_by_id => users.id)
#
module Commercial
  class ContractContact < ApplicationRecord
    include Trackable
    include HasContractHolder

    self.table_name = 'commercial_contract_contacts'

    belongs_to :contract_holder, polymorphic: true
    belongs_to :user, optional: true

    CONTRACT_CONTACT_TYPE = {
      procurement: 'procurement',
      invoicing: 'invoicing',
      loa: 'loa',
      renewals: 'renewals'
    }.freeze

    enum :contact_type, CONTRACT_CONTACT_TYPE

    validates_presence_of :name
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  end
end

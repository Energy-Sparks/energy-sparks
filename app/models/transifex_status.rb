# == Schema Information
#
# Table name: transifex_statuses
#
#  created_at   :datetime         not null
#  id           :bigint(8)        not null, primary key
#  record_id    :bigint(8)        not null
#  record_type  :string           not null
#  tx_last_pull :datetime
#  tx_last_push :datetime
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_transifex_statuses_uniqueness  (record_type,record_id) UNIQUE
#
class TransifexStatus < ApplicationRecord
  validates :record_type, :record_id, presence: true
  validates :record_id, uniqueness: { scope: :record_type }

  def self.find_by_model(model)
    find_by(record_type: model.class.name, record_id: model.id)
  end

  def self.create_for(model)
    create(record_type: model.class.name, record_id: model.id)
  end

  def self.create_for!(model)
    create!(record_type: model.class.name, record_id: model.id)
  end
end

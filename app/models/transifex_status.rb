# == Schema Information
#
# Table name: transifex_statuses
#
#  id           :bigint           not null, primary key
#  record_type  :string           not null
#  tx_last_pull :datetime
#  tx_last_push :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  record_id    :bigint           not null
#
# Indexes
#
#  index_transifex_statuses_uniqueness  (record_type,record_id) UNIQUE
#
class TransifexStatus < ApplicationRecord
  validates_presence_of :record_type, :record_id
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

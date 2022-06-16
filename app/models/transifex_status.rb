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

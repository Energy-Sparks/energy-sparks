class MoveAuditObervations < ActiveRecord::Migration[6.0]
  def up
    add_column :observations, :message_key, :integer, default: 0 # enum - defaults to :default
    add_index :observations, :message_key

    Observation.where(observation_type: :audit).find_each do |observation|
      observation.observable = observation.audit
      observation.observation_type = :observable
      observation.save!
    end

    Observation.where(observation_type: :audit_activities_completed).find_each do |observation|
      observation.observable = observation.audit
      observation.message_type = :completed
      observation.observation_type = :observable
      observation.save!
    end
  end

  def down
    Observation.where(observable_type: 'Audit', message_key: :default).find_each do |observation|
      observation.audit = observation.observable
      observation.observable = nil
      observation.observation_type = :audit
      observation.save!
    end

    Observation.where(observable_type: 'Audit', message_key: :completed).find_each do |observation|
      observation.audit = observation.observable
      observation.observable = nil
      observation.observation_type = :audit_activities_completed
      observation.save!
    end

    remove_column :observations, :message_key
  end
end

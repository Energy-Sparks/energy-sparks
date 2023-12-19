class MoveAuditObervations < ActiveRecord::Migration[6.0]
  def up
    add_column :observations, :observable_variation, :string, default: ''
    add_index :observations, :observable_variation

    Observation.where(observation_type: :audit).find_each do |observation|
      observation.observable = observation.audit
      observation.observation_type = :observable
      observation.observable_variation = ''
      observation.save!
    end

    Observation.where(observation_type: :audit_activities_completed).find_each do |observation|
      observation.observable = observation.audit
      observation.observation_type = :observable
      observation.observable_variation = 'ActivitiesCompleted'
      observation.save!
    end
  end

  def down
    Observation.for_observable('Audit', variation: '').find_each do |observation|
      observation.audit = observation.observable
      observation.observable = nil
      observation.observation_type = :audit
      observation.save!
    end

    Observation.for_observable('Audit', variation: 'ActivitiesCompleted').find_each do |observation|
      observation.audit = observation.observable
      observation.observable = nil
      observation.observation_type = :audit_activities_completed
      observation.save!
    end

    remove_column :observations, :observable_variation
  end
end

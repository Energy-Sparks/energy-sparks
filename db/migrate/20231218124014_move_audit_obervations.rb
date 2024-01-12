class MoveAuditObervations < ActiveRecord::Migration[6.0]
  def up
    Observation.where(observation_type: :audit).find_each do |observation|
      observation.observable = observation.audit
      observation.save!
    end

    Observation.where(observation_type: :audit_activities_completed).find_each do |observation|
      observation.observable = observation.audit
      observation.save!
    end

    Observation.where(observable_type: 'SchoolTarget').find_each do |observation|
      observation.observation_type = :school_target
      observation.save!
    end

    Observation.where(observable_type: 'Programme').find_each do |observation|
      observation.observation_type = :programme
      observation.save!
    end

    Observation.where(observable_type: 'TransportSurvey').find_each do |observation|
      observation.observation_type = :transport_survey
      observation.save!
    end
  end

  def down
    Observation.where(observation_type: :audit).find_each do |observation|
      observation.update_attribute(:observable, nil) # run without validations as audit observations now required observable_id
    end

    Observation.where(observation_type: :audit_activities_completed).find_each do |observation|
      observation.update_attribute(:observable, nil) # run without validations as audit observations now required observable_id
    end

    Observation.where(observable_type: %w(SchoolTarget Programme TransportSurvey)).find_each do |observation|
      observation.observation_type = 8 # change back to :observable (have changed the name, so using the ID instead here)
      observation.save!
    end
  end
end

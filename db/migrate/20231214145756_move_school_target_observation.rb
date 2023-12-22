class MoveSchoolTargetObservation < ActiveRecord::Migration[6.0]
  def up
    Observation.where(observation_type: :school_target).find_each do |observation|
      observation.observable = observation.school_target
      observation.observation_type = :observable
      observation.save!
    end
  end

  def down
    Observation.where(observable_type: 'SchoolTarget').find_each do |observation|
      observation.school_target = observation.observable
      observation.observable = nil
      observation.observation_type = :school_target
      observation.save!
    end
  end
end

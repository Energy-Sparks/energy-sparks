class MoveProgrammeObservation < ActiveRecord::Migration[6.0]
  def up
    Observation.where(observation_type: :programme).find_each do |observation|
      observation.observable = observation.programme
      observation.save!
    end
  end

  def down
    Observation.where(observation_type: :programme).find_each do |observation|
      observation.observable = nil
      observation.save!
    end
  end
end

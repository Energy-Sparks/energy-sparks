class MoveProgrammeObservation < ActiveRecord::Migration[6.0]
  def up
    Observation.where(observation_type: :programme).find_each do |observation|
      observation.obserable = observation.programme
      observation.observation_type = :observable
      observation.save!
    end
  end

  def down
    Observation.where(observable_type: 'Programme').find_each do |observation|
      observation.programme = observation.observable
      observation.observable = nil
      observation.observation_type = :programme
      observation.save!
    end
  end
end

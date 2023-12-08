class MoveProgrammeObservation < ActiveRecord::Migration[6.0]
  def up
    Observation.where(observation_type: :programme).find_each do |observation|
      observation.obserable = observation.programme
      observation.observation_type = :observable
      observation.save!
    end

    remove_column :observations, :programme_id
  end

  def down
    add_reference :observations, :programme, index: true

    Observation.where(observable_type: 'Programme').find_each do |observation|
      observation.programme = observation.observable
      observation.observable = nil
      observation.observation_type = :programme
      observation.save!
    end
  end
end

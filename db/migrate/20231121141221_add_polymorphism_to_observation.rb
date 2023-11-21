class AddPolymorphismToObservation < ActiveRecord::Migration[6.0]
  def change
    add_reference :observations, :observable, polymorphic: true, allow_nil: true
  end
end

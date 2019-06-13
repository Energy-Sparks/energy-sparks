class AddRelevancyFlagToEquivalences < ActiveRecord::Migration[6.0]
  def change
    add_column :equivalences, :relevant, :boolean, default: true
  end
end

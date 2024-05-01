class RemoveSandboxAttributeFromMeter < ActiveRecord::Migration[6.1]
  def change
    remove_column :meters, :sandbox, :boolean
  end
end

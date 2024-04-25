class RemoveSandboxAttributeFromMeter < ActiveRecord::Migration[6.1]
  def change
    remove_column :meters, :sandbox
  end
end

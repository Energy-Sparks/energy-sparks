class AddSandboxToMeters < ActiveRecord::Migration[6.0]
  def change
    add_column :meters, :sandbox, :boolean, default: false
  end
end

class CreateSolisCloudInstallationSchools < ActiveRecord::Migration[7.2]
  def change
    create_table :solis_cloud_installation_schools do |t|
      t.references :school, null: false, foreign_key: true
      t.references :solis_cloud_installation, null: false, foreign_key: true

      t.timestamps
    end
  end
end

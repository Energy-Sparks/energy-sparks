class CreateAreas < ActiveRecord::Migration[5.2]
  def change
    create_table :areas do |t|
      t.text      :type, null: false
      t.text      :title
      t.text      :description
      t.integer   :parent_area_id, index: true
      # t.boolean   :calendar,          default: true
      # t.boolean   :temperature,       default: false
      # t.boolean   :solar_irradiance,  default: false
      # t.boolean   :solar_pv,          default: false
      # t.boolean   :met_office,        default: false
    end
  end
end

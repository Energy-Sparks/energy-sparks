class CreateSchoolConfiguration < ActiveRecord::Migration[6.0]
  def change
    create_table :configurations do |t|
      t.references        :school,                  null: false, foreign_key: { on_delete: :cascade }
      t.json              :analysis_charts,         null: false, default: {}
      t.timestamps
    end
  end
end

class CreateAdvicePageSchoolBenchmarks < ActiveRecord::Migration[6.0]
  def change
    create_table :advice_page_school_benchmarks do |t|
      t.references :school, null: false, foreign_key: {on_delete: :cascade}
      t.references :advice_page, null: false, foreign_key: {on_delete: :cascade}
      t.integer :benchmarked_as, default: 0, null: false
      t.timestamps
    end
  end
end

class AddForeignKeys < ActiveRecord::Migration[6.0]
  def change
    # add_reference(:alerts, :alert_generation_run, foreign_key: true, on_delete: :cascade)
    add_foreign_key(:alert_errors, :alert_generation_runs, on_delete: :cascade)
    add_foreign_key(:alert_errors, :alert_types, on_delete: :cascade)
    add_foreign_key(:benchmark_results, :alert_generation_runs, on_delete: :cascade)
    add_foreign_key(:benchmark_results, :alert_types, on_delete: :cascade)

    add_foreign_key(:alert_generation_runs, :schools, on_delete: :cascade)
  end
end

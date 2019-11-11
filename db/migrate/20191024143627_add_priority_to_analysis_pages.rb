class AddPriorityToAnalysisPages < ActiveRecord::Migration[6.0]
  def change
    add_column :analysis_pages, :priority, :decimal, default: 0
  end
end

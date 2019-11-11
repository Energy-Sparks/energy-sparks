class AddCategoryToAnalysisPages < ActiveRecord::Migration[6.0]
  def change
    add_column :analysis_pages, :category, :integer, index: true
  end
end

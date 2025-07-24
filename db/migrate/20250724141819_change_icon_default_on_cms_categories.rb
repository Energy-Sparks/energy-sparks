class ChangeIconDefaultOnCmsCategories < ActiveRecord::Migration[7.2]
  def up
    change_column_default :cms_categories, :icon, 'question'
  end

  def down
    change_column_default :cms_categories, :icon, nil
  end
end

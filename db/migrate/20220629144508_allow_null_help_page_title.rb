class AllowNullHelpPageTitle < ActiveRecord::Migration[6.0]
  def change
    change_column_null :help_pages, :title, true
  end
end

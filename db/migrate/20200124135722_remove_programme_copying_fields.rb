class RemoveProgrammeCopyingFields < ActiveRecord::Migration[6.0]
  def up
    remove_column :programmes, :document_link
    remove_column :programmes, :title
  end
end

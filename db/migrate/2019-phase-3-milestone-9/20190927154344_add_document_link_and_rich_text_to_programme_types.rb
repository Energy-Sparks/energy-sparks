class AddDocumentLinkAndRichTextToProgrammeTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :programme_types, :document_link, :string
    add_column :programmes, :document_link, :string
    rename_column :programme_types, :description, :_old_description
    rename_column :programmes, :description, :_old_description
  end
end

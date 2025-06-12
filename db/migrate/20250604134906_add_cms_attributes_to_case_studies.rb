class AddCmsAttributesToCaseStudies < ActiveRecord::Migration[7.2]
  def change
    add_column :case_studies, :published, :boolean, null: false, default: false

    add_reference :case_studies, :created_by, foreign_key: { on_delete: :nullify, to_table: :users }
    add_reference :case_studies, :updated_by, foreign_key: { on_delete: :nullify, to_table: :users }
  end
end

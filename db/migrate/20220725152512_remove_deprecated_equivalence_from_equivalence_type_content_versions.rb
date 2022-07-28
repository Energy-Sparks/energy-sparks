class RemoveDeprecatedEquivalenceFromEquivalenceTypeContentVersions < ActiveRecord::Migration[6.0]
  def change
    remove_column :equivalence_type_content_versions, :_equivalence, :text
  end
end

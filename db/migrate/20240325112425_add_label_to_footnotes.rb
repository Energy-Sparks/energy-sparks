class AddLabelToFootnotes < ActiveRecord::Migration[6.1]
  def change
    add_column :comparison_footnotes, :label, :string
  end
end

class RichTextLinkRewrites < ActiveRecord::Migration[6.0]
  def change
    create_table :link_rewrites do |t|
      t.string :source
      t.string :target
      t.references :rewriteable, polymorphic: true
      t.timestamps
    end
  end
end

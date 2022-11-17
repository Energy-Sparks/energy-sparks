class RenameNotesIssues < ActiveRecord::Migration[6.0]
  def up
    rename_column :school_groups, :default_notes_admin_user_id, :default_issues_admin_user_id
    rename_column :notes, :note_type, :issue_type
    rename_table :notes, :issues
    execute "update action_text_rich_texts set record_type='Issue' where record_type='Note';"
    # Switch the enum values round to reflect re-ordering in model. Not normally a good idea but this hasn't been used much yet
    execute "update issues set issue_type = (case when issue_type=0 then 1 when issue_type=1 then 0 end);"
  end

  def down
    rename_column :school_groups, :default_issues_admin_user_id, :default_notes_admin_user_id
    rename_column :issues, :issue_type, :note_type
    rename_table :issues, :notes
    execute "update action_text_rich_texts set record_type='Note' where record_type='Issue';"
    execute "update notes set note_type = (case when note_type=0 then 1 when note_type=1 then 0 end);"
  end
end

class MakeIssuesPolymorphic < ActiveRecord::Migration[6.0]
  def change
    add_reference :issues, :issueable, polymorphic: true
    reversible do |dir|
      dir.up { Issue.update_all("issueable_id = school_id, issueable_type='School'") }
      dir.down { Issue.update_all('school_id = issueable_id') }
    end
    remove_reference :issues, :school
  end
end

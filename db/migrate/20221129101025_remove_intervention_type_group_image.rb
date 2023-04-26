class RemoveInterventionTypeGroupImage < ActiveRecord::Migration[6.0]
  def change
    ActiveStorage::Attachment.where(record_type: "InterventionTypeGroup").delete_all
  end
end

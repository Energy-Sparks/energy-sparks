class RenameInterventionTypeImage < ActiveRecord::Migration[6.0]
  def up
    ActiveStorage::Attachment.where(record_type: "InterventionType", name: 'image').update(name: 'image_en')
  end
  def down
    ActiveStorage::Attachment.where(record_type: "InterventionType", name: 'image_en').update(name: 'image')
  end
end

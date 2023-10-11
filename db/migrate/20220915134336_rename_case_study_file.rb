class RenameCaseStudyFile < ActiveRecord::Migration[6.0]
  def up
    ActiveStorage::Attachment.where(record_type: 'CaseStudy', name: 'file').update(name: 'file_en')
  end

  def down
    ActiveStorage::Attachment.where(record_type: 'CaseStudy', name: 'file_en').update(name: 'file')
  end
end

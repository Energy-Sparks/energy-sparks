# Helper method to create ActionText::Content with an attached file
def content_with_attachment(filename: 'spec/fixtures/images/placeholder.png', content_type: 'image/png')
  file = Rails.root.join(filename)

  blob = ActiveStorage::Blob.create_and_upload!(
    io: File.open(file),
    filename: File.basename(filename), content_type: content_type)

  attachment = ActionText::Attachment.from_attachable(blob)

  ActionText::Content.new("<div>#{attachment.to_html}</div>")
end

# Helper method to add an attachment to a record's rich text attribute
def add_attachment(record, attribute = :description, **kwargs)
  record.tap do |r|
    r.public_send("#{attribute}=", content_with_attachment(**kwargs))
  end
end

# Helper method to add an attachment and save the record
def add_attachment!(record, attribute = :description, **kwargs)
  add_attachment(record, attribute, **kwargs).tap(&:save!)
end

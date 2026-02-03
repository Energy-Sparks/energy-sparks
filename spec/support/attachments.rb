def add_attachment(object,
                   attribute: :description,
                   fixture: 'spec/fixtures/images/placeholder.png',
                   content_type: 'image/png')
  file = Rails.root.join(fixture)

  blob = ActiveStorage::Blob.create_and_upload!(
    io: File.open(file),
    filename: fixture.split('/').last,
    content_type: content_type
  )

  attachment_html = ActionText::Attachment.from_attachable(blob).to_html
  object.public_send("#{attribute}=", ActionText::Content.new("<div>#{attachment_html}</div>"))
end

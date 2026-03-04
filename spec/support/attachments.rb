# Builds an ActionText::Content object containing a single attachment.
#
# Used in tests to generate rich text content with an attached file.
#
# Example:
#   record.description = content_with_attachment
#
# Params:
# - filename: Path to file (default: spec/fixtures/images/placeholder.png)
# - content_type: MIME type (default: image/png)
def content_with_attachment(filename: 'spec/fixtures/images/placeholder.png', content_type: 'image/png')
  file = Rails.root.join(filename)

  blob = ActiveStorage::Blob.create_and_upload!(
    io: File.open(file),
    filename: File.basename(filename),
    content_type: content_type
  )

  attachment = ActionText::Attachment.from_attachable(blob)

  ActionText::Content.new("<div>#{attachment.to_html}</div>")
end

# Assigns an attachment to a record's rich text attribute (does not save).
#
# Example:
#   add_attachment(record)
#   record.save!
#
# Params:
# - record: ActiveRecord object
# - attribute: rich text attribute (default: :description)
# - filename/content_type: Passed to content_with_attachment
def add_attachment(record, attribute = :description, **kwargs)
  record.tap do |r|
    r.public_send("#{attribute}=", content_with_attachment(**kwargs))
  end
end

# Assigns an attachment and saves the record.
#
# Example:
#   add_attachment!(record)
# Params: same as add_attachment
def add_attachment!(record, attribute = :description, **kwargs)
  add_attachment(record, attribute, **kwargs).tap(&:save!)
end

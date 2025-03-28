class Youtube
  include ActiveModel::Model
  include ActiveModel::Attributes
  include GlobalID::Identification
  include ActionText::Attachable

  attribute :id

  def self.find(id)
    new(id: id)
  end

  def thumbnail_url
    "http://i3.ytimg.com/vi/#{id}/maxresdefault.jpg"
  end

  def to_trix_content_attachment_partial_path
    'youtubes/thumbnail'
  end
end

module StorageHelper
  def serve_from_storage(attachment, disposition = "inline")
    serve = disposition == "attachment" ? "attachment" : "inline"
    response.headers["Content-Disposition"] = "#{serve}; filename=\"#{attachment.filename}\""
    response.headers["Content-Type"] = attachment.content_type
    attachment.download do |chunk|
      response.stream.write(chunk)
    end
  end
end

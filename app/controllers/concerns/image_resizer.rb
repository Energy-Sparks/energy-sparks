module ImageResizer
  extend ActiveSupport::Concern

  private

  # Resize image to a max width of 1400px (current max container width) to prevent overly large files
  # and considering future inline use. As it is, these will never be wider than 510px.
  def resize_image(image, max_width: 1400)
    image || return

    ImageProcessing::MiniMagick
      .source(image)
      .resize_to_limit(max_width, nil)
      .call(destination: image.tempfile.path)
  end
end

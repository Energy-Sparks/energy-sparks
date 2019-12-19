module EnergySparksFormHelpers
  def fill_in_trix(identifier = 'trix-editor', with:)
    if @supports_js
      editor = first(identifier)
      editor.click.set(with)
    else
      first(identifier).send(:parent).all('input', visible: false).first.set(with)
    end
  end
end

RSpec.configure do |config|
  config.include EnergySparksFormHelpers
end

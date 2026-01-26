module EnergySparksFormHelpers
  def fill_in_trix(identifier = 'trix-editor', with:)
    if @supports_js
      editor = first(identifier)
      editor.click.set(with)
    else
      first(identifier).send(:parent).all('input', visible: false).first.set(with)
    end
  end

  def set_date(selector, date_string)
    page.execute_script <<~JS
      const input = document.querySelector('#{selector}');
      input.value = '#{date_string}';
      input.dispatchEvent(new Event('change', { bubbles: true }));
    JS
  end
end

RSpec.configure do |config|
  config.include EnergySparksFormHelpers
end

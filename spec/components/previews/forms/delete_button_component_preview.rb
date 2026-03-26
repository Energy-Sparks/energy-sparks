# frozen_string_literal: true

module Forms
  class DeleteButtonComponentPreview < ViewComponent::Preview
    # @param url "URL to target with delete request"
    # @param name "Button label"
    def example(url: 'http://example.org', name: 'Delete')
      render(Forms::DeleteButtonComponent.new(url, name))
    end

    # @param url "URL to target with delete request"
    # @param deletable "Value to be returned by resource.deletable?"
    def deletable(url: 'http://example.org', deletable: true)
      render(Forms::DeleteButtonComponent.new(url, resource: Struct.new(:deletable?).new(deletable)))
    end
  end
end

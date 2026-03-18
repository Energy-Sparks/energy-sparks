module Forms
  class DeleteButtonComponent < ApplicationComponent
    def initialize(url, name = 'Delete', resource: nil, size: :sm, **_kwargs)
      super
      @url = url
      @name = name
      @size = size
      @resource = resource
    end

    def render?
      return true unless @resource && @resource.respond_to?(:deletable?)
      @resource.deletable?
    end
  end
end

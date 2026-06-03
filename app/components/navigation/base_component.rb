module Navigation
  class BaseComponent < ApplicationComponent
    attr_reader :current_user

    def initialize(current_user: nil, **kwargs)
      super(id: 'page-nav', **kwargs)
      @current_user = current_user
    end

    def ability
      @ability ||= Ability.new(@current_user)
    end

    def can?(permission, context)
      ability.can?(permission, context)
    end
  end
end

# frozen_string_literal: true

module ActionController
  class Responder
    # looks like https://github.com/heartcombo/responders/issues/237
    def redirect_to(*args, **kwargs)
      kwargs[:allow_other_host] = true
      controller.redirect_to(*args, **kwargs)
    end
  end
end

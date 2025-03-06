# frozen_string_literal: true

module PagyHelper
  def run_with_temporary_pagy_default(**kwargs)
    originals = Pagy::DEFAULT.slice(*kwargs.keys)
    Pagy::DEFAULT.merge!(kwargs)
    begin
      yield
    ensure
      Pagy::DEFAULT.merge!(originals)
    end
  end
end

RSpec.configure do |config|
  config.include PagyHelper
end

# frozen_string_literal: true

module PagyHelper
  def run_with_temporary_pagy_default(**kwargs)
    original = Pagy::OPTIONS
    Pagy.const_set(:OPTIONS, Pagy::OPTIONS.merge(kwargs))
    begin
      yield
    ensure
      Pagy.const_set(:OPTIONS, original)
    end
  end
end

RSpec.configure do |config|
  config.include PagyHelper
end

# frozen_string_literal: true

def with_modified_env(options, &block)
  ClimateControl.modify(options, &block)
end

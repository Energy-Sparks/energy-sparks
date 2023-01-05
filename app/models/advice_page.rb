class AdvicePage < ApplicationRecord
  extend Mobility
  include TransifexSerialisable

  translates :learn_more, backend: :action_text
end

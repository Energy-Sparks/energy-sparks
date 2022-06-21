module Transifex
  class Response < OpenStruct
    def initialize(completed: false, data: nil, content: nil)
      super(completed: completed, data: data, content: content)
    end

    def completed?
      completed
    end
  end
end

class ApplicationJob < ActiveJob::Base
  def priority
    10
  end
end

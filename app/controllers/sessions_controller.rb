class SessionsController < Devise::SessionsController

  #Needed for merit integration
  def create
    super do |user|
      @session = user
    end
  end

end
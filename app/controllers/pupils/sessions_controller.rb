module Pupils
  class SessionsController < ApplicationController
    skip_before_action :authenticate_user!
    load_and_authorize_resource :school

    def new
    end

    def create
      password = params.require(:pupil).fetch(:password)
      if password.blank?
        redirect_back fallback_location: new_pupils_school_session_path(@school), alert: 'Please enter a password'
      else
        pupil = @school.users.pupil.to_a.find {|user| user.pupil_password == password}
        if pupil
          sign_in(:user, pupil)
          redirect_to pupils_school_path(@school), notice: 'Signed in successfully'
        else
          redirect_back fallback_location: new_pupils_school_session_path(@school), alert: "Sorry, that password doesn't work!"
        end
      end
    end
  end
end

module Pupils
  class SessionsController < ApplicationController
    skip_before_action :authenticate_user!

    def create
      school = School.find(params.require(:pupil).fetch(:school_id))
      password = params.require(:pupil).fetch(:password)
      if password.blank?
        redirect_to new_user_session_path(role: 'pupil', school: school), alert: 'Please enter a password'
      else
        sign_in_pupil(school, password)
      end
    rescue ActiveRecord::RecordNotFound
      redirect_back fallback_location: new_user_session_path(role: 'pupil'), alert: 'Please select a school'
    end

    private

    def sign_in_pupil(school, password)
      pupil = school.authenticate_pupil(password)
      if pupil
        sign_in(:user, pupil)
        redirect_to pupils_school_path(school), notice: 'Signed in successfully'
      else
        redirect_to new_user_session_path(role: 'pupil', school: school), alert: "Sorry, that password doesn't work!"
      end
    end
  end
end

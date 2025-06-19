module Pupils
  class SessionsController < ApplicationController
    skip_before_action :authenticate_user!

    def create
      school = School.find(params.require(:pupil).fetch(:school_id))
      password = params.require(:pupil).fetch(:password)
      if password.blank?
        redirect_to new_user_session_path(role: 'pupil', school: school), alert: t('errors.messages.enter_a_password')
      else
        sign_in_pupil(school, password)
      end
    rescue ActiveRecord::RecordNotFound
      redirect_back fallback_location: new_user_session_path(role: 'pupil'), alert: t('errors.messages.select_a_school')
    end

    private

    def sign_in_pupil(school, password)
      pupil = school.authenticate_pupil(password)
      if pupil
        sign_in(:user, pupil)
        redirect_path = stored_location_for(:user) || pupils_school_path(school)
        redirect_to redirect_path, notice: t('devise.sessions.new.signed_in_successfully')
      else
        redirect_to new_user_session_path(role: 'pupil', school: school), alert: t('errors.messages.invalid_password')
      end
    end
  end
end

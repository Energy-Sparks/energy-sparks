# frozen_string_literal: true

class UsersController < ApplicationController
  include ApplicationHelper
  load_and_authorize_resource except: [:index]
  skip_before_action :authenticate_user!, only: :index

  def index
    if current_user.present?
      redirect_to user_path(current_user)
    else
      store_location_for(:user, users_path)
      redirect_to new_user_session_path(disable_pupil: true), notice: I18n.t('users.index.redirect')
    end
  end

  def show
    authorize! :read, @user
    render :show, layout: 'dashboards'
  end

  def edit
    authorize! :edit, @user
    render :edit, layout: 'dashboards'
  end

  def update
    authorize! :update, @user
    if @user.update(user_params)
      redirect_to user_path(@user), notice: I18n.t('users.edit.account_updated')
    else
      render :edit, layout: 'dashboards'
    end
  end

  def edit_password
    authorize! :edit, @user
    render :edit_password, layout: 'dashboards'
  end

  def update_password
    authorize! :update, @user
    if @user.update_with_password(password_params)
      bypass_sign_in(@user) unless current_user.admin?
      redirect_to user_path(@user), notice: I18n.t('users.edit_password.password_updated')
    else
      render :edit_password, layout: 'dashboards'
    end
  end

  private

  def user_params
    params.require(:user)
          .permit(:name, :email, :staff_role_id, :preferred_locale)
  end

  def password_params
    params.require(:user)
          .permit(:current_password, :password, :password_confirmation)
  end
end

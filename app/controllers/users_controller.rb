# frozen_string_literal: true

class UsersController < ApplicationController
  include ApplicationHelper
  load_and_authorize_resource

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
  end

  private

  def user_params
    params.require(:user)
          .permit(:name, :email, :staff_role_id)
  end
end

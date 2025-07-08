# frozen_string_literal: true

class AdminController < ApplicationController
  include Adminable
  before_action :admin_authorized?
  before_action :set_breadcrumbs

  def index; end

  private

  def set_breadcrumbs; end
end

# frozen_string_literal: true

class AdminController < ApplicationController
  include Adminable
  before_action :admin_authorized?

  def index; end
end

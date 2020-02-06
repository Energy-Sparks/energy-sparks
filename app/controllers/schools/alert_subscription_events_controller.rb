class Schools::AlertSubscriptionEventsController < ApplicationController
  load_and_authorize_resource :school
  load_and_authorize_resource through: :school

  def show
  end
end

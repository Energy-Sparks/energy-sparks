module Schools
  class AdviceController < ApplicationController
    load_and_authorize_resource :school
  end
end

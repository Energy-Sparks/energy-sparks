module Admin
  class ProcurementRoutesController < AdminController
    before_action :header_fix_enabled
    load_and_authorize_resource
  end
end

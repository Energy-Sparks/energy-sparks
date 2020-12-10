class VersionController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    versions = Gem.loaded_specs["energy-sparks_analytics"].source
    render plain: versions
  end
end

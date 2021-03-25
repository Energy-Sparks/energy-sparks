module Schools
  class ConsentsController < ApplicationController
    load_and_authorize_resource :school

    def show
      @consent_grant = ConsentGrant.new(consent_statement: ConsentStatement.current, name: current_user.name, job_title: current_user.role.humanize.titleize, school_name: @school.name)
    end

    def create
      @consent_grant = ConsentGrant.new(school_consent_params.merge(user: current_user, school: @school))
      if @consent_grant.save
        redirect_to school_path(@school)
      else
        render :show
      end
    end

  private

    def school_consent_params
      params.require(:consent_grant).permit(:school_name, :name, :job_title, :consent_statement_id)
    end
  end
end

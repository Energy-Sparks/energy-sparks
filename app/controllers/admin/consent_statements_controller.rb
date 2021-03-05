module Admin
  class ConsentStatementsController < AdminController
    load_and_authorize_resource

    def index
      @consent_statements = ConsentStatement.by_date
    end

    def show
    end

    def new
    end

    def edit
    end

    def create
      if @consent_statement.save
        redirect_to admin_consent_statements_path, notice: 'Consent statement was successfully created.'
      else
        render :new
      end
    end

    def update
      if @consent_statement.editable?
        if @consent_statement.update(consent_statement_params)
          redirect_to admin_consent_statements_path, notice: 'Consent statement was successfully updated.'
        else
          render :edit
        end
      else
        flash[:error] = 'This consent statement is no longer editable'
        render :edit
      end
    end

    def destroy
      # TODO only if not referenced yet
      @consent_statement.destroy
      redirect_to admin_consent_statements_path, notice: 'Consent statement was successfully destroyed.'
    end

    private

    def consent_statement_params
      params.require(:consent_statement).permit(:title, :content)
    end
  end
end

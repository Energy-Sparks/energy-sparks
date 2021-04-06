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

    def publish
      publisher = ConsentStatements::Publisher.new
      if publisher.publish(@consent_statement)
        redirect_to admin_consent_statements_path, notice: 'Consent statement set to current'
      else
        redirect_to admin_consent_statements_path, alert: publisher.error_message
      end
    end

    def destroy
      if @consent_statement.editable?
        @consent_statement.destroy
        redirect_to admin_consent_statements_path, notice: 'Consent statement was successfully deleted.'
      else
        redirect_to admin_consent_statements_path, notice: 'This consent statement is no longer deletable'
      end
    end

    private

    def consent_statement_params
      params.require(:consent_statement).permit(:title, :content)
    end
  end
end

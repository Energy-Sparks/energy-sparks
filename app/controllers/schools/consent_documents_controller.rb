module Schools
  class ConsentDocumentsController < ApplicationController
    load_resource :school
    load_and_authorize_resource :consent_document, through: :school

    def index
    end

    def show
    end

    def new
      @consent_document = ConsentDocument.new
    end

    def create
      @consent_document.school = @school
      if @consent_document.save
        redirect_to school_consent_documents_path, notice: 'Your bill was successfully uploaded.'
      else
        render :new
      end
    end

    def update
      if @consent_document.update(consent_document_params)
        redirect_to school_consent_documents_path, notice: "The bill was successfully updated."
      else
        render :edit
      end
    end

    def destroy
      @consent_document.delete
      redirect_to school_consent_documents_path, notice: "The bill was successfully deleted."
    end

    private

    def consent_document_params
      params.require(:consent_document).permit(:title, :description, :file)
    end
  end
end

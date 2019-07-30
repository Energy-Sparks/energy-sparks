module Onboarding
  class ContactsController < BaseController
    def new
      @contact = @school_onboarding.school.contacts.new
    end

    def edit
      @contact = @school_onboarding.school.contacts.find(params[:id])
    end

    def create
      @contact = @school_onboarding.school.contacts.new(contact_params)
      if @contact.save
        redirect_to new_onboarding_completion_path(@school_onboarding)
      else
        render :new
      end
    end

    def update
      @contact = @school_onboarding.school.contacts.find(params[:id])
      if @contact.update(contact_params)
        redirect_to new_onboarding_completion_path(@school_onboarding)
      else
        render :edit
      end
    end

    def destroy
      contact = @school_onboarding.school.contacts.find(params[:id])
      contact.destroy
      redirect_to new_onboarding_completion_path(@school_onboarding)
    end

  private

    def contact_params
      params.require(:contact).permit(
        :description,
        :email_address,
        :mobile_phone_number,
        :name
      )
    end
  end
end

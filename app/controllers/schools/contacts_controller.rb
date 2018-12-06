class Schools::ContactsController < ApplicationController
  load_and_authorize_resource :school
  load_and_authorize_resource :contact, through: :school

  def index
  end

  def new
  end

  def edit
  end

  def create
    if @contact.save
      redirect_to school_contacts_path(@school), notice: "#{@contact.display_name} was successfully created."
    else
      render :new
    end
  end

  def update
    if @contact.update(contact_params)
      redirect_to school_contacts_path(@school), notice: "#{@contact.display_name} was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    display_name = @contact.display_name
    @contact.destroy
    redirect_to school_contacts_path(@school), notice: "#{display_name} was successfully deleted."
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

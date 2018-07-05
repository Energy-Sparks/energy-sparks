class Schools::ContactsController < ApplicationController
  load_and_authorize_resource :contact
  load_and_authorize_resource :school, find_by: :slug

  skip_before_action :authenticate_user!
  before_action :set_school
  before_action set_contact: [:edit, :update]

  def index
    @contacts = Contact.where(school: @school)
  end

  def new
    @contact = Contact.new
  end

  def edit
  end

  def create
    @contact = Contact.new(contact_params)
    @contact.school = @school
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

  # Use callbacks to share common setup or constraints between actions.
  def set_school
    @school = School.find(params[:school_id])
  end

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(
      :description,
      :email_address,
      :mobile_phone_number,
      :name
    )
  end
end

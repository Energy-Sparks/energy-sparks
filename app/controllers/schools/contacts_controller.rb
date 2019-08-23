class Schools::ContactsController < ApplicationController
  load_and_authorize_resource :school
  load_and_authorize_resource :contact, through: :school

  def index
    @standalone_contacts = @contacts.where(user_id: nil)
    @account_contacts = @contacts.where.not(user_id: nil)
    @accounts_without_contacts = @school.users.alertable.left_outer_joins(:contact).where('contacts.id IS NULL')
  end

  def new
    if params[:user_id]
      user = @school.users.alertable.find(params[:user_id])
      authorize! :enable_alerts, user
      @contact.popualate_from_user(user)
    end
  end

  def edit
  end

  def create
    authorize! :enable_alerts, @contact.user if @contact.user
    if @contact.save
      redirect_to school_contacts_path(@school), notice: "Alerts enabled for #{@contact.display_name}"
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
      :name,
      :user_id
    )
  end
end

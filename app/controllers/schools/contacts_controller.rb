class Schools::ContactsController < ApplicationController
  load_and_authorize_resource :school
  load_and_authorize_resource :contact, through: :school
  before_action :set_breadcrumbs

  def index
    authorize! :manage_users, @school
    @standalone_contacts = @contacts.where(user_id: nil)
    @account_contacts = @contacts.where.not(user_id: nil)
    @accounts_without_contacts = @school.users.alertable.left_outer_joins(:contacts).where('contacts.id IS NULL')
  end

  def new
    if params[:user_id]
      user = @school.users.alertable.find(params[:user_id])
      authorize! :enable_alerts, user
      @contact.populate_from_user(user)
    end
  end

  def edit
  end

  def create
    authorize! :enable_alerts, @contact.user if @contact.user
    if @contact.save
      redirect_user(current_user_notice: 'Alerts enabled', notice: "Alerts enabled for #{@contact.display_name}")
    else
      render :new
    end
  end

  def update
    if @contact.update(contact_params)
      redirect_user(current_user_notice: 'Details updated', notice: "#{@contact.display_name} was successfully updated")
    else
      render :edit
    end
  end

  def destroy
    @contact.destroy
    redirect_user(current_user_notice: 'Alerts disabled', notice: "Alerts disabled for #{@contact.display_name}")
  end

private

  def set_breadcrumbs
    @breadcrumbs = [{ name: I18n.t('manage_school_menu.manage_alert_contacts') }]
  end

  def contact_params
    params.require(:contact).permit(
      :description,
      :email_address,
      :mobile_phone_number,
      :name,
      :user_id,
      :staff_role_id,
      user_attributes: [:id, :preferred_locale]
    )
  end

  def redirect_user(current_user_notice:, notice:)
    if @contact.user == current_user
      redirect_to school_path(@school), notice: current_user_notice
    else
      redirect_to school_contacts_path(@school), notice: notice
    end
  end
end

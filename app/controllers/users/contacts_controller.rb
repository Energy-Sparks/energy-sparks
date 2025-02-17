module Users
  class ContactsController < ApplicationController
    load_resource :user
    load_and_authorize_resource through: :user

    def index
      @schools = if @user.group_admin?
                   @user.school_group.schools.visible.by_name
                 elsif @user.has_other_schools?
                   @user.cluster_schools.visible.by_name
                 else
                   [@user.school]
                 end
      @show_clusters = @schools.any? { |s| s.school_group_cluster.present? }
      render :index, layout: 'dashboards'
    end

    # Sometimes creating the contact is failing as its invalid...?
    # trying to touch! the user model when inserting.
    def create
      @contact = Contact.create(
        user_id: @user.id,
        school_id: params[:school_id],
        name: @user.display_name,
        email_address: @user.email,
        staff_role: @user.staff_role
      )
      if @contact.save
        redirect_to user_contacts_path(@user), notice: t('users.contacts.create.subscribed')
      else
        redirect_to user_contacts_path(@user), notice: t('users.contacts.create.failed')
      end
    end

    def destroy
      @contact.destroy
      redirect_to user_contacts_path(@user), notice: t('users.contacts.create.unsubscribed')
    end
  end
end

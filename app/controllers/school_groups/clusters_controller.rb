module SchoolGroups
  class ClustersController < ApplicationController
    load_and_authorize_resource :school_group
    before_action :redirect_unless_authorised
    load_and_authorize_resource :cluster, class: 'SchoolGroupCluster', through: :school_group
    #rescue_from CanCan::AccessDenied, :with => :redirect_unless_authorised

    before_action :header_fix_enabled
    before_action :set_breadcrumbs

    def index
    end

    def create
      @cluster = @school_group.clusters.build(cluster_params)
      if @cluster.save
        redirect_to school_group_clusters_path(@school_group), notice: I18n.t('school_groups.clusters.created')
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @cluster.update(cluster_params)
        redirect_to school_group_clusters_path(@school_group), notice: I18n.t('school_groups.clusters.updated')
      else
        render :edit
      end
    end

    def destroy
      @cluster.destroy
      redirect_to school_group_clusters_path(@school_group), notice: I18n.t('school_groups.clusters.deleted')
    end

    private

    def redirect_unless_authorised
      redirect_to school_group_path(@school_group) and return unless can?(:update_settings, @school_group)
    end

    def cluster_params
      params.require(:school_group_cluster).permit(:name)
    end

    def set_breadcrumbs
      @breadcrumbs = [
        { name: I18n.t('common.schools'), href: schools_path },
        { name: @school_group.name, href: school_group_path(@school_group) },
        { name: t('school_groups.clusters.title').capitalize }
      ]
    end
  end
end

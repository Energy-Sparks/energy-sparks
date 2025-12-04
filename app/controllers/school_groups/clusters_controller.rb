module SchoolGroups
  class ClustersController < BaseController
    layout -> { Flipper.enabled?(:group_settings, current_user) ? 'group_settings' : 'application' }

    before_action :redirect_unless_authorised
    load_and_authorize_resource :cluster, class: 'SchoolGroupCluster', through: :school_group

    before_action :breadcrumbs

    def index
    end

    def create
      @cluster = @school_group.clusters.build(cluster_params)
      if @cluster.save
        redirect_to school_group_clusters_path(@school_group), notice: I18n.t('school_groups.clusters.messages.created')
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @cluster.update(cluster_params)
        redirect_to school_group_clusters_path(@school_group), notice: I18n.t('school_groups.clusters.messages.updated')
      else
        render :edit
      end
    end

    def assign
      if @cluster
        @cluster.school_ids += cluster_params['school_ids']
        notice = I18n.t('school_groups.clusters.messages.assigned', cluster: @cluster.name, count: cluster_params[:school_ids].count)
      else
        notice = I18n.t('school_groups.clusters.messages.select_cluster')
      end
      redirect_to school_group_clusters_path(@school_group), notice: notice
    end

    def unassign
      @cluster.school_ids -= cluster_params['school_ids'].map!(&:to_i)
      redirect_to school_group_clusters_path(@school_group), notice: I18n.t('school_groups.clusters.messages.unassigned', cluster: @cluster.name, count: cluster_params[:school_ids].count)
    end

    def destroy
      @cluster.destroy
      redirect_to school_group_clusters_path(@school_group), notice: I18n.t('school_groups.clusters.messages.deleted')
    end

    private

    def redirect_unless_authorised
      redirect_to school_group_path(@school_group) and return unless can?(:update_settings, @school_group)
    end

    def cluster_params
      params.fetch(:school_group_cluster, {}).permit(:name, school_ids: [])
        .with_defaults(school_ids: [])
    end

    def breadcrumbs
      build_breadcrumbs([name: t('school_groups.clusters.index.title').capitalize, href: school_group_clusters_path(@school_group)])
      @breadcrumbs << { name: @cluster.new_record? ? I18n.t('school_groups.clusters.labels.new') : @cluster.name } if @cluster
    end
  end
end

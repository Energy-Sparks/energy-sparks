module Admin
  module Commercial
    class ContractHolderContractsController < AdminController
      include SchoolGroupBreadcrumbs

      load_and_authorize_resource :funder, instance_name: 'contract_holder'
      load_and_authorize_resource :school_group, instance_name: 'contract_holder'
      load_and_authorize_resource :school, instance_name: 'contract_holder'

      def index
        @contracts = @contract_holder.contracts.by_start_date
        if @contract_holder.is_a?(SchoolGroup)
          @school_group = @contract_holder
          breadcrumbs
          render :index, layout: 'group_settings'
        elsif @contract_holder.is_a?(School)
          @school = @contract_holder
          render :index
        else
          render :index
        end
      end

      def breadcrumbs
        build_breadcrumbs([{ name: t('school_groups.titles.contracts') }])
      end
    end
  end
end

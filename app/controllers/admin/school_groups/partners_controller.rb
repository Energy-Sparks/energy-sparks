# frozen_string_literal: true

module Admin
  module SchoolGroups
    class PartnersController < AdminController
      include SchoolGroupBreadcrumbs

      load_and_authorize_resource :school_group

      before_action :breadcrumbs

      layout 'group_settings'

      def show
        @partners = Partner.all.order(:name)
        @positions = @school_group.school_group_partners.inject({}) do |positions, school_group_partner|
          positions[school_group_partner.partner_id] = school_group_partner.position
          positions
        end
      end

      def update
        position_attributes = params.permit(school_group_partners: [:position, :partner_id]).fetch(:school_group_partners) { {} }
        @school_group.update_school_partner_positions!(position_attributes)
        redirect_to admin_school_group_path(@school_group), notice: 'Partners updated'
      end

      def breadcrumbs
        build_breadcrumbs([{ name: t('school_groups.titles.partners') }])
      end
    end
  end
end

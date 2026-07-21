# frozen_string_literal: true

module Admin
  class OrganisationStatementsController < AdminController
    load_and_authorize_resource :organisation_statement, class: 'ImpactReport::OrganisationStatement'

    def index
      @organisation_statements = ImpactReport::OrganisationStatement.all
    end

    def create
      @organisation_statement =  ImpactReport::OrganisationStatement.build(organisation_statement_params)
      if @organisation_statement.save
        redirect_to admin_organisation_statements_path, notice: 'Organisation statement has been created'
      else
        render :new
      end
    end

    def update
      if @organisation_statement.update(organisation_statement_params)
        redirect_to admin_organisation_statements_path, notice: 'Organisation statement has been updated'
      else
        render :edit
      end
    end

    def destroy
      if @organisation_statement.destroy
        redirect_back_or_to(admin_organisation_statements_path, notice: 'Organisation statement has been deleted')
      else
        redirect_back_or_to(admin_organisation_statements_path,
                            alert: @organisation_statement.errors.full_messages.to_sentence)
      end
    end

    def make_current
      notice = if @organisation_statement.make_current!
                 'Organisation statement is now current and live on the website'
               else
                 'Unable to make current'
               end
      redirect_back_or_to(admin_organisation_statements_path, notice:)
    end

    private

    def organisation_statement_params
      params.expect(
        organisation_statement: %i[academic_year actions activities average_primary_saving average_secondary_saving
                                   best_saving current
                                   efficiency_report_link
                                   primary_carbon_saving primary_cost_saving primary_saving_electricity
                                   primary_saving_electricity primary_saving_gas pupils schools
                                   secondary_carbon_saving secondary_cost_saving
                                   secondary_saving_electricity secondary_saving_gas
                                   staff total_carbon_savings total_cost_savings]
      )
    end
  end
end

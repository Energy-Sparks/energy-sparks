# frozen_string_literal: true

class AddOrganisationToCaseStudies < ActiveRecord::Migration[7.2]
  def change
    add_reference :case_studies, :organisation, polymorphic: true, index: true
  end
end

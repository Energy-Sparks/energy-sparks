class CreateEstablishments < ActiveRecord::Migration[7.2]
  def change
    # rubocop:disable Metrics/BlockLength
    create_table(:lists_establishments) do |t|
      t.integer   :la_code
      t.integer   :establishment_number
      t.string    :establishment_name
      t.integer   :establishment_status_code
      t.string    :postcode
      t.string    :school_website
      t.integer   :type_of_establishment_code
      t.string    :uprn
      t.integer   :number_of_pupils
      t.string    :percentage_fsm
      t.datetime  :last_changed_date
      t.integer   :establishment_type_group_code
      t.datetime  :open_date
      t.datetime  :close_date
      t.integer   :phase_of_education_code
      t.integer   :statutory_low_age
      t.integer   :statutory_high_age
      t.integer   :boarders_code
      t.string    :nursery_provision_name
      t.integer   :official_sixth_form_code
      t.string    :diocese_code
      t.integer   :school_capacity
      t.datetime  :census_date
      t.integer   :trusts_code
      t.integer   :federations_code
      t.integer   :ukprn
      t.string    :street
      t.string    :locality
      t.string    :address3
      t.string    :town
      t.string    :county_name
      t.string    :gor_code
      t.string    :district_administrative_code
      t.string    :administrative_ward_code
      t.string    :parliamentary_constituency_code
      t.string    :urban_rural_code
      t.string    :gssla_code_name
      t.integer   :easting
      t.integer   :northing
      t.integer   :previous_la_code
      t.string    :msoa_code
      t.string    :lsoa_code
      t.integer   :fsm

      t.timestamps
    end
    # rubocop:enable Metrics/BlockLength
  end
end

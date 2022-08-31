class RemoveNullConstraintFromUserOnConsentGrants < ActiveRecord::Migration[6.0]
  def change
    change_column_null :consent_grants, :user_id, true
  end
end

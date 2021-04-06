class AssociateConsentDocumentsAndMeterReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :consent_documents_meter_reviews, id: false do |t|
      t.belongs_to :consent_document
      t.belongs_to :meter_review
    end
  end
end

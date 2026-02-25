require 'rails_helper'

module Lists
  describe EstablishmentLink do
    it_behaves_like 'a csvimportable', './spec/fixtures/import_establishments/zipped_sample.zip'
  end
end

require 'rails_helper'

RSpec.describe ResourceFile, type: :model do
  describe '#user_guide_download_path' do
    it 'returns a download path for the user guide if available' do
      ResourceFile.delete_all
      expect(ResourceFile.user_guide_download_path).to eq('/resources')
      rf = ResourceFile.new
      rf.title = 'Energy Sparks User Guide'
      rf.save(validate: false)
      expect(ResourceFile.user_guide_download_path).to eq("/resources/#{rf.id}/download")
    end
  end
end

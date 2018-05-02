def sign_in_user(role = :guest, school_id = nil)
  @request.env["devise.mapping"] = Devise.mappings[:user]
  user = FactoryBot.create(:user, role: role, school_id: school_id)
  sign_in user
end


module FeatureTestHelpers
  def sign_in(user = double('user'))
    if user.nil?
      allow(request.env['warden']).to receive(:authenticate!).and_throw(:warden, {:scope => :user})
      allow(controller).to receive(:current_user).and_return(nil)
    else
      allow(request.env['warden']).to receive(:authenticate!).and_return(user)
      allow(controller).to receive(:current_user).and_return(user)
    end
  end
end
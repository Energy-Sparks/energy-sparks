def sign_in_user(role = :guest, school_id = nil)
  request.env['devise.mapping'] = Devise.mappings[:user]
  user = FactoryBot.create(role, school_id: school_id)
  sign_in user
end

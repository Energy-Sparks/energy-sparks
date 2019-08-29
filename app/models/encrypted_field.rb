class EncryptedField
  KEY = ActiveSupport::KeyGenerator.new(
    Rails.application.secrets.secret_key_base
  ).generate_key(
    Rails.application.secrets.encrypted_field_salt,
    ActiveSupport::MessageEncryptor.key_len
  ).freeze
  private_constant :KEY

  def self.encrypt(value)
    encryptor.encrypt_and_sign(value)
  end

  def self.decrypt(value)
    encryptor.decrypt_and_verify(value)
  end

  def self.encryptor
    ActiveSupport::MessageEncryptor.new(KEY)
  end

  class Type < ActiveRecord::Type::String
    def deserialize(value)
      EncryptedField.decrypt(value) if value
    end

    def serialize(value)
      EncryptedField.encrypt(value)
    end
  end
end

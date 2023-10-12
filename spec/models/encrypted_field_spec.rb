require 'rails_helper'

describe EncryptedField do
  it 'can encrypt end decrypt strings' do
    encrypted = EncryptedField.encrypt('testing 123')
    expect(encrypted).not_to eq('testing 123')
    expect(EncryptedField.decrypt(encrypted)).to eq('testing 123')
  end

  it 'handles nils' do
    encrypted = EncryptedField.encrypt(nil)
    expect(encrypted).not_to eq(nil)
    expect(EncryptedField.decrypt(encrypted)).to eq(nil)
  end

  it 'empty strings' do
    encrypted = EncryptedField.encrypt('')
    expect(encrypted).not_to eq('')
    expect(EncryptedField.decrypt(encrypted)).to eq('')
  end
end

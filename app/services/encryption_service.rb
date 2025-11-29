# frozen_string_literal: true

class EncryptionService
  CIPHER = 'aes-256-cbc'

  SECRET_KEY = ENV.fetch('CONFIGURATION_SECRET_KEY', SecureRandom.hex)
  IV = ENV.fetch('CONFIGURATION_IV', SecureRandom.hex[0..15])

  def self.encrypt(text)
    cipher = OpenSSL::Cipher.new(CIPHER)
    cipher.encrypt
    cipher.key = SECRET_KEY
    cipher.iv = IV
    encrypted = cipher.update(text) + cipher.final
    Base64.strict_encode64(encrypted)
  end

  def self.decrypt(encrypted_text)
    decoded = Base64.strict_decode64(encrypted_text)
    cipher = OpenSSL::Cipher.new(CIPHER)
    cipher.decrypt
    cipher.key = SECRET_KEY
    cipher.iv = IV
    cipher.update(decoded) + cipher.final
  rescue OpenSSL::Cipher::CipherError, ArgumentError
    nil
  end
end

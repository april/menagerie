# frozen_string_literal: true

module SecurityToken

  def self.generate
    SecureRandom.base64(32).delete("+/=")[0..31]
  end

end

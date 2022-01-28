class JsonWebTokenService
  SECRET_KEY = Rails.env == "production" ? ENV["SECRET_KEY_BASE"].freeze : Rails.application.secrets.secret_key_base.freeze

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new decoded
  end
end

class Account < ApplicationRecord
  has_secure_password validations: :false

  belongs_to :user, dependent: :destroy
  has_many :sessions, dependent: :destroy

  before_validation :ensure_user_exists, on: :create

  normalizes :email_address, :first_name, :last_name, with: ->(e) { e.strip.downcase }

  validates :email_address, uniqueness: { case_sensitive: false }, format: URI::MailTo::EMAIL_REGEXP, presence: true
  validates :provider, inclusion: { in: [ "google" ], message: "%{value} no es un proveedor válido" }, if: :oauth_account?

  validates :uid, presence: true, if: :oauth_account?
  validates :uid, length: { maximum: 255 }, allow_blank: true, if: :oauth_account?
  validates :uid, uniqueness: { scope: :provider, message: "ya existe un identificador para este proveedor" }, if: :oauth_account?

  validates :oauth_token, presence: true, if: :oauth_account?

  def self.find_or_create_by_oauth(auth)
    account = find_or_initialize_by(email_address: auth.info.email)

    if account.new_record?
      account.assign_attributes(
        first_name: extract_first_name(auth),
        last_name: extract_last_name(auth),
        provider: auth.provider.downcase,
        uid: auth.uid,
        oauth_token: auth.credentials.token,
        oauth_expires_at: parse_oauth_expiration(auth),
        avatar_url: auth.info.image,
        password: SecureRandom.hex(32)
      )
      account.save
    elsif account.provider.nil?
      account.update(
        provider: auth.provider.downcase,
        uid: auth.uid,
        oauth_token: auth.credentials.token,
        oauth_expires_at: parse_oauth_expiration(auth),
        avatar_url: auth.info.image
      )
    else
      account.update(
        oauth_token: auth.credentials.token,
        oauth_expires_at: parse_oauth_expiration(auth),
        avatar_url: auth.info.image
      )
    end

    account
  end

  def oauth_account?
    provider.present?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def ensure_user_exists
    self.build_user() unless user.present?
  end

  class << self
    private

    def extract_first_name(auth)
      auth.info.first_name&.downcase || auth.info.name&.split.first.downcase || "sin nombre"
    end

    def extract_last_name(auth)
      auth.info.last_name&.downcase || auth.info.name&.split.last.downcase || "sin apellido"
    end

    def parse_oauth_expiration(auth)
      return nil unless auth.credentials.expires_at
      Time.at(auth.credentials.expires_at)
    end
  end
end

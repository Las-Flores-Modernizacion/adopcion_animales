class User < ApplicationRecord
  has_one :account
  has_many :reports

  delegate :full_name, :avatar_url, to: :account, allow_nil: true
end

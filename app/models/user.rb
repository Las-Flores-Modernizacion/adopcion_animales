class User < ApplicationRecord
  has_one :account

  delegate :full_name, to: :account
end

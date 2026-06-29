class User < ApplicationRecord
  haz_one :account

  delegate :full_name, to: :account
end

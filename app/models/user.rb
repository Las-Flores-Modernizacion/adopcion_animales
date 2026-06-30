class User < ApplicationRecord
  has_one :account
  has_many :reports

  delegate :full_name, to: :account
end

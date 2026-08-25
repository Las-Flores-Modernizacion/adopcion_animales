class User < ApplicationRecord
  has_one :account
  has_many :reports, dependent: :destroy
  has_many :sightings, dependent: :destroy
  has_many :adoption_requests, dependent: :destroy

  delegate :full_name, :avatar_url, to: :account, allow_nil: true
end

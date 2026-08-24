class AdoptionRequest < ApplicationRecord
  HOUSING_TYPES = %w[casa departamento].freeze

  belongs_to :report
  belongs_to :user

  validates :phone_number, presence: true
  validates :housing_type, inclusion: { in: HOUSING_TYPES }
  validates :motivation, presence: true
  validates :household_members_count, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :other_pets_details, presence: true, if: :other_pets?
end

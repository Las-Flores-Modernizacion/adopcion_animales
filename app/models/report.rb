class Report < ApplicationRecord
  belongs_to :user

  has_one_attached :photo

  validates :photo, presence: { message: "La foto no puede faltar." }
end

class Report < ApplicationRecord
  has_one_attached :photo do |attachable|
  attachable.variant :thumb, resize_to_limit: [ 300, 300 ], saver: { quality: 80 }, format: :webp, preprocessed: true
  end

  validates :photo, presence: true
end

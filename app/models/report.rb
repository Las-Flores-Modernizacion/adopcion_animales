class Report < ApplicationRecord
  belongs_to :user
  belongs_to :location
  has_one :animal, dependent: :destroy

  has_many_attached :photo

  accepts_nested_attributes_for :animal, update_only: true

  validates :location, presence: true
  validate :photo_presence
  validate :accepted_file_types
  validate :accepted_file_size

  scope :own, -> { where(user_id: Current.user.id) }
  scope :published, -> { where(draft: false).or(where(draft: nil)) }
  scope :community, -> { published.where.not(user_id: Current.user.id) }

  def save_with_location_and_photos(location_params, photos)
    ActiveRecord::Base.transaction do
      location = Location.create!(
        latitude: location_params[:browser_lat],
        longitude: location_params[:browser_lng]
      )
      self.location = location
      self.photo.attach(photos) if photos.present?
      save!
    end
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def photo_presence
    errors.add(:photo, "Debes adjuntar al menos una fotografía del animal.") unless photo.attached?
  end

  def accepted_file_types
    extensiones_aceptadas = %w[image/jpeg image/png image/webp image/avif image/heic]

    if photo.attached?
      photo.each do |p|
        unless extensiones_aceptadas.include?(p.content_type)
          errors.add(:photo, "El formato de una de las imágenes no es válido")
        end
      end
    end
  end

  def accepted_file_size
    if photo.attached?
      photo.each do |p|
        if p.blob.byte_size >= 20.megabytes
          errors.add(:photo, "Cada imagen debe pesar menos de 20 MB")
        end
      end
    end
  end
end

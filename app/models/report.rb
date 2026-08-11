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

  def self.build_draft(user, location_params, photos)
    report = user.reports.build(draft: true)

    report.build_location(
      latitude: location_params[:browser_lat],
      longitude: location_params[:browser_lng]
    )

    report.photo.attach(photos) if photos.present?
    report
  end

  private

  def photo_presence
    errors.add(:photo, "debes adjuntar al menos una fotografía del animal.") unless photo.attached?
  end

  def accepted_file_types
    extensiones_aceptadas = %w[image/jpeg image/png image/webp image/avif image/heic]

    if photo.attached?
      photo.each do |p|
        content_type = p.blob&.content_type || p.content_type
        unless extensiones_aceptadas.include?(content_type)
          errors.add(:photo, "el formato de una de las imágenes no es válido")
        end
      end
    end
  end

  def accepted_file_size
    if photo.attached?
      photo.each do |p|
        byte_size = p.blob&.byte_size || p.size
        if byte_size && byte_size >= 20.megabytes
          errors.add(:photo, "cada imagen debe pesar menos de 20 MB")
        end
      end
    end
  end
end

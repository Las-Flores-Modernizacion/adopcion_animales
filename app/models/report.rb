class Report < ApplicationRecord
  belongs_to :user

  has_one_attached :photo

  validates :photo, presence: { message: "La foto no puede faltar." }

  validate :tipo_de_archivo_aceptado
  validate :tamaño_archivo_aceptado

  private

  def tipo_de_archivo_aceptado
    extensiones_aceptadas = %w[
      image/jpeg
      image/png
      image/webp
    ]

    if photo.attached?
      tipo_archivo = photo.content_type
      unless extensiones_aceptadas.include?(tipo_archivo) #GPT dice que unless queda mejor que "if !extensiones_aceptadas.include?(extension_archivo)"
        errors.add(:photo, message: "El formato del archivo no es valido")
      end
    end
  end

  # Se permiten archivos de hasta 20 MB, si es menos o más lo cambiamos.
  def tamaño_archivo_aceptado 
    if photo.attached?
      tamaño_archivo = photo.blob.byte_size
      if tamaño_archivo >= 20.megabytes
        errors.add(:photo, message: "Se acepta un tamaño de hasta 20 MB")
      end
    end
  end
end

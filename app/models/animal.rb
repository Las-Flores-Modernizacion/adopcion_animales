class Animal < ApplicationRecord
  enum :size, { pequeño: 0, mediano: 1, grande: 2 }
  enum :species, { perro: 0, gato: 1 }

  # Normalizaciones
  normalizes :color, with: ->(color) { color.strip.downcase }

  # Validaciones
  validates :color,
    format: { with: /\A[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+\z/, message: "Solo se permiten letras." },
    length: { minimum: 3, maximum: 40, message: "Solo se permiten colores con más de 3 letras y menos de 41" }
end

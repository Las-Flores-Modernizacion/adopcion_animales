class Animal < ApplicationRecord
  enum :size, { pequeño: 0, mediano: 1, grande: 2 }
  enum :species, { perro: 0, gato: 1 }

  # Normalizaciones
  normalizes :color, :answer_to_name, :race, :unique_detail,  with: ->(e) { e.strip.downcase }

  # Validaciones
  validates :color,
    format: { with: /\A[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+\z/, message: "Solo se permiten letras." },
    length: { minimum: 3, maximum: 40, message: "Solo se permiten colores con más de 3 letras y menos de 41" }

  validates :age, numericality: { only_integer: true, less_than_or_equal_to: 25 }

  validates :answer_to_name,
    format: { with: /\A[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+\z/, message: "Solo se permiten letras." },
    length: { maximum: 40, message: "Como máximo puedes escribir 40 carácteres" }

  validates :race,
    format: { with: /\A[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+\z/, message: "Solo se permiten letras." },
    length: { maximum: 40, message: "Como máximo puedes escribir 40 carácteres" }
  validates :unique_detail,

    length: { maximum: 40, message: "Como máximo puedes escribir 40 carácteres" }
end

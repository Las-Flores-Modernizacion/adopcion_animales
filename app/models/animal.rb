class Animal < ApplicationRecord
  belongs_to :report

  enum :size, { pequeño: 0, mediano: 1, grande: 2 }
  enum :species, { perro: 0, gato: 1 }

  normalizes :color, :answer_to_name, :race, :unique_detail, with: ->(e) { e.strip.downcase }

  validates :species, presence: { message: "debes seleccionar una especie" }
  validates :size, presence: { message: "debes seleccionar un tamaño aproximado" }

  validates :color,
    format: { with: /\A[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+\z/, message: "solo se permiten letras" },
    length: { minimum: 3, maximum: 40, message: "debe tener entre 3 y 40 caracteres" },
    allow_blank: true

  validates :age,
    numericality: { only_integer: true, less_than_or_equal_to: 25, message: "debe ser un número válido" },
    allow_nil: true

  validates :answer_to_name,
    format: { with: /\A[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+\z/, message: "solo se permiten letras" },
    length: { maximum: 40, message: "máximo 40 caracteres" },
    allow_blank: true

  validates :race,
    format: { with: /\A[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+\z/, message: "solo se permiten letras" },
    length: { maximum: 40, message: "máximo 40 caracteres" },
    allow_blank: true

  validates :unique_detail,
    length: { maximum: 40, message: "máximo 40 caracteres" },
    allow_blank: true
end

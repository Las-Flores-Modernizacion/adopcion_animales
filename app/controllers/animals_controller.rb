class AnimalsController < ApplicationController
  RESULTS_LIMIT = 20

  def index
    animals = Animal.all
    animals = animals.where(species: params[:species]) if params[:species].present?
    animals = animals.where(size: params[:size]) if params[:size].present?
    animals = animals.where(search_condition, query: "%#{params[:query].strip.downcase}%") if params[:query].present?

    render json: { data: animals.order(created_at: :desc).limit(RESULTS_LIMIT).map { |animal| animal_json(animal) } }
  end

  private

  def search_condition
    "color LIKE :query OR race LIKE :query OR unique_detail LIKE :query OR answer_to_name LIKE :query"
  end

  def animal_json(animal)
    { id: animal.id, label: animal_label(animal) }
  end

  def animal_label(animal)
    parts = [ animal.species&.titleize, animal.size&.titleize, animal.color, animal.race ].compact
    parts << "\"#{animal.answer_to_name}\"" if animal.answer_to_name.present?
    parts.join(" · ")
  end
end

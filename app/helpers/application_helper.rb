module ApplicationHelper
  STATUS_BADGE_VARIANTS = {
    "perdido" => "red",
    "avistado" => "blue",
    "en_transito" => "purple",
    "en_proceso_adopcion" => "yellow",
    "adoptado" => "green",
    "encontrado" => "green"
  }.freeze

  STATUS_LABELS = {
    "perdido" => "Perdido",
    "avistado" => "Avistado",
    "en_transito" => "En tránsito",
    "en_proceso_adopcion" => "En proceso de adopción",
    "adoptado" => "Adoptado",
    "encontrado" => "Encontrado"
  }.freeze

  def status_badge_variant(status)
    STATUS_BADGE_VARIANTS.fetch(status.to_s, "neutral")
  end

  def status_label(status)
    STATUS_LABELS.fetch(status.to_s, status.to_s.titleize)
  end
end

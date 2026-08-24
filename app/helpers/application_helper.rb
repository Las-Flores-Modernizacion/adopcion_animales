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

  STATUS_MAP_COLORS = {
    "perdido" => "#ef4444",
    "avistado" => "#3b82f6",
    "en_transito" => "#a855f7",
    "en_proceso_adopcion" => "#eab308",
    "adoptado" => "#22c55e",
    "encontrado" => "#22c55e"
  }.freeze

  def status_map_color(status)
    STATUS_MAP_COLORS.fetch(status.to_s, "#6b7280")
  end
end

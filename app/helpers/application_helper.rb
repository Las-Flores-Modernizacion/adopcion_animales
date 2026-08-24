module ApplicationHelper
  STATUS_BADGE_CLASSES = {
    "perdido" => "bg-red-100 text-red-800 dark:bg-red-950/60 dark:text-red-300",
    "avistado" => "bg-blue-100 text-blue-800 dark:bg-blue-950/60 dark:text-blue-300",
    "en_transito" => "bg-purple-100 text-purple-800 dark:bg-purple-950/60 dark:text-purple-300",
    "en_proceso_adopcion" => "bg-amber-100 text-amber-800 dark:bg-amber-950/60 dark:text-amber-300",
    "adoptado" => "bg-green-100 text-green-800 dark:bg-green-950/60 dark:text-green-300",
    "encontrado" => "bg-emerald-100 text-emerald-800 dark:bg-emerald-950/60 dark:text-emerald-300"
  }.freeze

  STATUS_LABELS = {
    "perdido" => "Perdido",
    "avistado" => "Avistado",
    "en_transito" => "En tránsito",
    "en_proceso_adopcion" => "En proceso de adopción",
    "adoptado" => "Adoptado",
    "encontrado" => "Encontrado"
  }.freeze

  def status_badge_classes(status)
    STATUS_BADGE_CLASSES.fetch(status.to_s, "bg-neutral-100 text-neutral-800 dark:bg-neutral-800 dark:text-neutral-200")
  end

  def status_label(status)
    STATUS_LABELS.fetch(status.to_s, status.to_s.titleize)
  end
end

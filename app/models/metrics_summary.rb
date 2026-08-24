# Agrega los números que muestra el panel de métricas del admin. Todo se
# calcula sobre reportes publicados: un borrador no representa un caso real
# todavía.
class MetricsSummary
  def total_reports
    @total_reports ||= published_reports.count
  end

  def total_users
    Account.count
  end

  def status_counts
    @status_counts ||= Report::STATUSES.keys.map(&:to_s).index_with { 0 }.merge(published_reports.group(:status).count)
  end

  def resolution_rate
    return 0.0 if total_reports.zero?

    resolved = status_counts.fetch("adoptado", 0) + status_counts.fetch("encontrado", 0)
    (resolved.to_f / total_reports * 100).round(1)
  end

  def reports_created_since(days)
    published_reports.where(created_at: days.days.ago..).count
  end

  def sightings_created_since(days)
    Sighting.where(created_at: days.days.ago..).count
  end

  def species_counts
    Animal.joins(:report).merge(published_reports).group(:species).count
  end

  def size_counts
    Animal.joins(:report).merge(published_reports).group(:size).count
  end

  def adoption_stats
    requests = AdoptionRequest.joins(:report)

    {
      total: AdoptionRequest.count,
      pending: requests.where(reports: { status: "en_proceso_adopcion" }).distinct.count(:report_id),
      approved: requests.where(reports: { status: "adoptado" }).distinct.count(:report_id),
      rejected: requests.where.not(reports: { status: %w[en_proceso_adopcion adoptado] }).distinct.count(:report_id)
    }
  end

  private

  def published_reports
    @published_reports ||= Report.published
  end
end

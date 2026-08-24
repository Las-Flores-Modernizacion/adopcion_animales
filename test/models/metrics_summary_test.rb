require "test_helper"

class MetricsSummaryTest < ActiveSupport::TestCase
  setup do
    @metrics = MetricsSummary.new
  end

  test "total_reports cuenta solo reportes publicados" do
    attach_photo(reports(:reporte))
    reports(:reporte).update!(draft: true)
    assert_equal 1, @metrics.total_reports
  end

  test "status_counts incluye todos los estados, incluso en cero" do
    counts = @metrics.status_counts

    assert_equal Report::STATUSES.keys.map(&:to_s).sort, counts.keys.sort
    assert_equal 2, counts["perdido"]
    assert_equal 0, counts["adoptado"]
  end

  test "resolution_rate es 0 cuando no hay reportes resueltos" do
    assert_equal 0.0, @metrics.resolution_rate
  end

  test "resolution_rate cuenta encontrados y adoptados sobre el total" do
    attach_photo(reports(:reporte))
    reports(:reporte).update!(status: "encontrado")
    assert_equal 50.0, @metrics.resolution_rate
  end

  private

  def attach_photo(report)
    report.photo.attach(io: file_fixture("colibri estatico.png").open, filename: "colibri.png", content_type: "image/png")
  end
end

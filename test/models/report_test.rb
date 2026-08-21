require "test_helper"

class ReportTest < ActiveSupport::TestCase
  setup do
    @reporte = reports(:reporte)
  end

  test "el reporte es válido" do # Podria no hacerlo
    @reporte.photo.attach(
      io: file_fixture("colibri estatico.png").open,
      filename: "prueba",
      content_type: "image/png"
    )
    assert @reporte.valid?, @reporte.errors.full_messages
  end

  test "el reporte tiene una foto adjunta?" do
    reporte = @reporte
    reporte.photo.attach(
      io: file_fixture("colibri estatico.png").open,
      filename: "prueba",
      content_type: "image/png"
    )
    assert reporte.photo.attached?

    reporte.photo.purge
    assert_not reporte.photo.attached?
  end

  test "solo se aceptan formatos válidos en los archivos" do
    reporte = @reporte
    reporte.photo.attach(
      io: file_fixture("Apropiación artística.docx").open,
      filename: "prueba2",
      content_type: "application/pdf"
    )
    assert_not reporte.save
    # reporte.errors[:photo]

    reporte.photo.purge
    reporte = @reporte
    reporte.photo.attach(
      io: file_fixture("colibri estatico.png").open,
      filename: "prueba",
      content_type: "image/png"
    )
    assert reporte.save
  end

  test "el tamaño del archivo debe ser menor a 20 MegaBytes" do
    reporte = @reporte
    reporte.photo.attach(
      io: file_fixture("colibri estatico.png").open,
      filename: "prueba",
      content_type: "image/png"
    )

    # p reporte.photo.blob.byte_size.megabytes
    assert reporte.save
  end
end

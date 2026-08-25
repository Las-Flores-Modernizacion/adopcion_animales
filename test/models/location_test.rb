require "test_helper"

class LocationTest < ActiveSupport::TestCase
  setup do
    @obelisco = locations(:obelisco)
  end

  test "no debe ser válido sin latitud" do
    location = Location.new(longitude: -58.381592)
    assert_not location.valid?
    assert_includes location.errors[:latitude], "no puede estar en blanco"
  end

  test "no debe ser válido sin longitud" do
    location = Location.new(latitude: -34.603722)
    assert_not location.valid?
    assert_includes location.errors[:longitude], "no puede estar en blanco"
  end

  test "debe poder guardar exitosamente en la base de datos" do
    location = Location.new(latitude: -34.521, longitude: -58.452)
    assert location.save
  end
end

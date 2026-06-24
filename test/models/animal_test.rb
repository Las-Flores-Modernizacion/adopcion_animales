require "test_helper"

class AnimalTest < ActiveSupport::TestCase
  setup do
    @tito = animals(:tito)
  end

  test "el color debe ser solo letras" do
    animal = @tito
    animal.color = "123456"
    assert_not animal.save

    animal.color = "a354"
    assert_not animal.save

    animal.color = "marrón"
    assert animal.save
  end
end

require "test_helper"

class AnimalTest < ActiveSupport::TestCase
  setup do
    @tito = animals(:tito)
    @tasha = animals(:tasha)
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

  test "edad hasta 25" do
    animal = @tasha
    animal.age = 120
    assert_not animal.save

    animal.age = "doce"
    assert_not animal.save

    animal.age = 25
    assert animal.save
  end
end

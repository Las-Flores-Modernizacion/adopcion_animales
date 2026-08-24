require "test_helper"

class AnimalTest < ActiveSupport::TestCase
  setup do
    @tito = animals(:tito) # Obtiene el objeto Animal correspondiente al fixture :tito.
    @tasha = animals(:tasha)
  end

  test "el color debe ser solo letras" do
    animal = @tito # Crea una variable local que hace referencia al mismo objeto que @tito.
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

  test "el nombre debe ser solo letras" do
    animal = @tito
    animal.answer_to_name = "1234567890¡?'¿+{}-.,;:#^`~!$%&/()°|¬"
    assert_not animal.save

    animal.answer_to_name = "     toto1        "
    assert_not animal.save

    animal.answer_to_name = "toto 1     "
    assert_not animal.save

    animal.answer_to_name = "toto   "
    assert animal.save
  end

  test "la raza solo puede tener letras" do
    animal = @tito
    animal.race = "1234567890¡?'¿+{}-.,;:#^`~!$%&/()°|¬"
    assert_not animal.save

    animal.race = "     caniche112        "
    assert_not animal.save

    animal.race = "caniche 1     "
    assert_not animal.save

    animal.race = "Caniche   "
    assert animal.save
  end

  test "máximos caracteres en detalle único" do
    animal = @tito
    animal.unique_detail = "El perrito tenia una pequeña lastimadura en la patita derecha"
    assert_not animal.save

    animal.unique_detail = "Estaba renguito"
    assert animal.save
  end
end

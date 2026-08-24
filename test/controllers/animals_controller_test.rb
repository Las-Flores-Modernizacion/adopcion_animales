require "test_helper"

class AnimalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tomas = users(:tomas)
  end

  test "redirige a root si no está autenticado" do
    get animals_path
    assert_redirected_to root_path
  end

  test "index devuelve los animales en formato json" do
    sign_in_as @tomas
    get animals_path, as: :json

    assert_response :success
    body = JSON.parse(response.body)
    ids = body["data"].map { |a| a["id"] }
    assert_includes ids, animals(:tito).id
    assert_includes ids, animals(:tasha).id
  end

  test "index filtra por especie y por texto de búsqueda" do
    sign_in_as @tomas

    get animals_path, params: { species: "perro", query: "caniche" }, as: :json
    body = JSON.parse(response.body)
    ids = body["data"].map { |a| a["id"] }
    assert_includes ids, animals(:tito).id

    get animals_path, params: { query: "no existe este texto" }, as: :json
    body = JSON.parse(response.body)
    assert_empty body["data"]
  end
end

require "test_helper"

class AccountTest < ActiveSupport::TestCase
  setup do
    @tomas = accounts(:tomas)
  end

  test "es válida sin password, porque no es una cuenta con login por password" do
    account = Account.new(email_address: "nueva@example.com", first_name: "Nueva", last_name: "Cuenta")
    assert account.valid?
  end

  test "requiere un email válido y único" do
    account = Account.new(first_name: "Sin", last_name: "Email")
    assert_not account.valid?
    assert_includes account.errors[:email_address], "can't be blank"

    account.email_address = "no-es-un-email"
    assert_not account.valid?

    account.email_address = @tomas.email_address
    assert_not account.valid?
    assert_includes account.errors[:email_address], "has already been taken"
  end

  test "una cuenta oauth requiere provider, uid y oauth_token válidos" do
    account = Account.new(email_address: "oauth@example.com", first_name: "O", last_name: "Auth", provider: "google")
    assert_not account.valid?
    assert_includes account.errors[:uid], "can't be blank"
    assert_includes account.errors[:oauth_token], "can't be blank"

    account.provider = "facebook"
    account.uid = "123"
    account.oauth_token = "token"
    assert_not account.valid?
    assert_includes account.errors[:provider], "facebook no es un proveedor válido"
  end

  test "find_or_create_by_oauth crea la cuenta y el usuario si el email no existe" do
    auth = build_auth(email: "nuevo@example.com")

    assert_difference [ "Account.count", "User.count" ], 1 do
      account = Account.find_or_create_by_oauth(auth)
      assert account.persisted?
      assert_equal "google", account.provider
      assert_equal "uid-123", account.uid
    end
  end

  test "find_or_create_by_oauth completa el provider de una cuenta preexistente sin oauth" do
    auth = build_auth(email: @tomas.email_address)

    assert_no_difference [ "Account.count", "User.count" ] do
      account = Account.find_or_create_by_oauth(auth)
      assert_equal @tomas.id, account.id
      assert_equal "google", account.reload.provider
      assert_equal "uid-123", account.uid
    end
  end

  test "find_or_create_by_oauth actualiza el token de una cuenta oauth existente" do
    @tomas.update!(provider: "google", uid: "uid-viejo", oauth_token: "token-viejo")
    auth = build_auth(email: @tomas.email_address, uid: "uid-viejo", token: "token-nuevo")

    account = Account.find_or_create_by_oauth(auth)

    assert_equal "token-nuevo", account.reload.oauth_token
    assert_equal "uid-viejo", account.uid # no se pisa el uid en una cuenta ya vinculada
  end

  test "full_name concatena nombre y apellido" do
    assert_equal "#{@tomas.first_name} #{@tomas.last_name}", @tomas.full_name
  end

  private

  def build_auth(email:, uid: "uid-123", token: "token-123")
    OmniAuth::AuthHash.new(
      provider: "google",
      uid: uid,
      info: OmniAuth::AuthHash::InfoHash.new(
        email: email,
        first_name: "Nombre",
        last_name: "Apellido",
        name: "Nombre Apellido",
        image: "https://lh3.googleusercontent.com/a/default-user"
      ),
      credentials: OmniAuth::AuthHash.new(token: token, expires_at: 1.hour.from_now.to_i)
    )
  end
end

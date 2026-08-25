ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionDispatch
  class IntegrationTest
    # Logs in through the real Google OAuth callback flow, mocked via OmniAuth's
    # test mode, so requests carry the same signed session cookie production does.
    def sign_in_as(user)
      account = user.account
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new(
        provider: "google",
        uid: account.uid.presence || "test-uid-#{account.id}",
        info: OmniAuth::AuthHash::InfoHash.new(
          email: account.email_address,
          first_name: account.first_name,
          last_name: account.last_name,
          name: "#{account.first_name} #{account.last_name}"
        ),
        credentials: OmniAuth::AuthHash.new(token: "test-token", expires_at: 1.hour.from_now.to_i)
      )

      post "/auth/google/callback"
      assert_response :redirect
    ensure
      OmniAuth.config.mock_auth[:google] = nil
    end
  end
end

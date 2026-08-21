# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.base_uri     :self
    policy.object_src   :none
    policy.frame_ancestors :none
    policy.form_action  :self

    # Avatars come from the account's Google profile photo (accounts.avatar_url).
    policy.img_src      :self, :data, "https://*.googleusercontent.com"
    policy.font_src     :self

    # embla-carousel, floating-ui and tom-select are pinned from jsdelivr in config/importmap.rb;
    # tom-select's stylesheet is also loaded from jsdelivr in the layout.
    policy.script_src   :self, "https://cdn.jsdelivr.net"
    # Inline style="" attributes (progress bars, avatar stacking offsets) can't carry a nonce,
    # so style-src needs unsafe-inline in addition to the CDN stylesheet.
    policy.style_src    :self, :unsafe_inline, "https://cdn.jsdelivr.net"

    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap and inline scripts.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end

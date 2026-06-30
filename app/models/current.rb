class Current < ActiveSupport::CurrentAttributes
  attribute :session

  delegate :account, to: :session, allow_nil: true
  delegate :user, to: :account, allow_nil: true
end

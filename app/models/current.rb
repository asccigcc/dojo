# Request-scoped globals. Only the signed-in user lives here.
class Current < ActiveSupport::CurrentAttributes
  attribute :user
end

# frozen_string_literal: true

ActiveJob::Status.store = :solid_cache_store
ActiveJob::Status.options = { includes: %i[status exception] }
ActiveJob::Status.options = { expires_in: 1.days.to_i }

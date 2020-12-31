# frozen_string_literal: true

ActiveJob::Status.store = :redis_cache_store

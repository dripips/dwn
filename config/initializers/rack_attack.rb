Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

Rack::Attack.throttle("api/get", limit: 60, period: 1.minute) do |request|
  request.ip if request.path.start_with?("/api/get")
end

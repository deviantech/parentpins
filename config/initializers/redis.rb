# Connect to redis, make it available prettily
REDIS = Redis::Namespace.new("ppin_#{Rails.env}", :redis => Redis.new)

module Rails
  def self.redis
    REDIS
  end
end
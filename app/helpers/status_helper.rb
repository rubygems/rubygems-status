module StatusHelper
  # Render service last update time
  # @param ping [Ping] service ping instance
  # @return [String]
  def service_last_update_time(ping)
    diff = ping.seconds_ago
    (diff < 60) ? "#{diff.to_i}s" : time_ago_in_words(ping.last_seen)
  end
end

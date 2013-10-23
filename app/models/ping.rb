class Ping < ActiveRecord::Base
  def down?
    unknown? || status == "down"
  end

  def up?
    !unknown? && status == "up"
  end

  def unknown?
    last_seen.nil?
  end

  def seconds_ago
    current_time.to_i - last_seen.to_i
  end

  def state
    return "unknown" if unknown?
    status
  end
  
  def current_time
    Time.now
  end
end

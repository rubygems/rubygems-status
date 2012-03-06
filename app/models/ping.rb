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
    Time.now - last_seen
  end

  def state
    return "unknown" if unknown?
    status
  end
end

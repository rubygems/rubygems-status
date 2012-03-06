class Ping < ActiveRecord::Base
  def down?
    status == "down"
  end
end

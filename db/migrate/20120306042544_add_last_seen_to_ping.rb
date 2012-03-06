class AddLastSeenToPing < ActiveRecord::Migration
  def change
    add_column :pings, :last_seen, :timestamp
  end
end

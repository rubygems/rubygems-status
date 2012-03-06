class AddCriticalToPing < ActiveRecord::Migration
  def change
    add_column :pings, :critical, :boolean
  end
end

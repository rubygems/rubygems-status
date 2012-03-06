class AddDescriptionToPing < ActiveRecord::Migration
  def change
    add_column :pings, :description, :text
  end
end

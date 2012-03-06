class CreatePings < ActiveRecord::Migration
  def change
    create_table :pings do |t|
      t.string :service
      t.string :status

      t.timestamps
    end
  end
end

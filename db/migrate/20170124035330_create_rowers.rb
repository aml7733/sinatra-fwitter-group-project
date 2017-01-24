class CreateRowers < ActiveRecord::Migration
  def change
    create_table :rowers do |t|
      t.string :name
      t.integer :weight
      t.integer :power
      t.integer :boat_id
    end
  end
end

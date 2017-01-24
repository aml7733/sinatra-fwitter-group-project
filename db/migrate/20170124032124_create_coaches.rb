class CreateCoaches < ActiveRecord::Migration
  def change
    create_table :coaches do |t|
      t.string :name
      t.string :password_digest
      t.string :club_name
    end
  end
end

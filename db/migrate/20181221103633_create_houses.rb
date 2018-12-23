class CreateHouses < ActiveRecord::Migration[5.2]
  def change
    create_table :houses do |t|
      t.string :name
      t.text :address
      t.boolean :rented, :default => false
      t.timestamps
    end
  end
end

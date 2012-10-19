class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities, :id => false do |t|
      t.integer :id, :limit => 8
      t.string :name
      t.string :latitude
      t.string :longitude

      t.timestamps
    end
  end
end

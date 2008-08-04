class CreateFavorites < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.string :name
      t.string :uri

      t.timestamps
    end
  end

  def self.down
    drop_table :favorites
  end
end

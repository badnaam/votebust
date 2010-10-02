class CreateCities < ActiveRecord::Migration
  def self.up
    create_table :cities do |t|
      t.string :name
      t.integer :vote_topics_count
      t.index :vote_topics_count
      t.index :name
      t.timestamps
    end
  end

  def self.down
    drop_table :cities
  end
end

class CreateVStates < ActiveRecord::Migration
  def self.up
    create_table :v_states do |t|
      t.string :name
      t.integer :vote_topics_count
      t.index :vote_topics_count
      t.index :name
      t.timestamps
    end
  end

  def self.down
    drop_table :v_states
  end
end

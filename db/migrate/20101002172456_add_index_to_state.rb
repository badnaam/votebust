class AddIndexToState < ActiveRecord::Migration
  def self.up
      add_index :v_states, :vote_topics_count
      add_index :v_states, :name
  end

  def self.down
  end
end

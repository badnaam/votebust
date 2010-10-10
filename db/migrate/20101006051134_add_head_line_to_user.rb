class AddHeadLineToUser < ActiveRecord::Migration
  def self.up
      add_column :users, :hdline, :string, {:limit => 140}
  end

  def self.down
      remove_column :users, :hdline
  end
end

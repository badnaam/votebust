class AddAboutAndStatusToUser < ActiveRecord::Migration
  def self.up
      add_column :users, :about, :string, {:limit => 250}
      add_column :users, :status, :string, {:limit => 140}
  end

  def self.down
      remove_column :users, :about
      remove_column :users, :status
  end
end

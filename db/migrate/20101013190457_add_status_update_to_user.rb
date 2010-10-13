class AddStatusUpdateToUser < ActiveRecord::Migration
  def self.up
      add_column :users, :status_update_yes, :boolean, {:default => 1}
  end

  def self.down
      remove_column :users, :status_update_yes
  end
end

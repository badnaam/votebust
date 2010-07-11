class AddProcessingToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :processing, :boolean
  end

  def self.down
    remove_column :users, :processing
  end
end

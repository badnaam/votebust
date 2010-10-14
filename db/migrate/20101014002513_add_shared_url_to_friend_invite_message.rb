class AddSharedUrlToFriendInviteMessage < ActiveRecord::Migration
  def self.up
      add_column :friend_invite_messages, :shared_url, :string, {:limit => 255}
  end

  def self.down
      remove_column :friend_invite_messages, :shared_url
  end
end

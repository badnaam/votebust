class CreateFriendInviteMessages < ActiveRecord::Migration
    def self.up
        create_table :friend_invite_messages do |t|
            t.string :message
            t.text :emails

            t.references :user
            t.timestamps
        end
    end

    def self.down
        drop_table :friend_invite_messages
    end
end

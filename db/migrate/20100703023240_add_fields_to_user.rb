class AddFieldsToUser < ActiveRecord::Migration
    def self.up
        add_column :users, :crypted_password, :string, :null => false
        add_column :users, :password_salt, :string, :null => false
        add_column :users, :persistence_token, :string, :null => false
        add_column :users, :single_access_token, :string, :null => false
        add_column :users, :perishable_token, :string, :null => false
        add_column :users, :login_count, :integer, :null => false, :default => 0
        add_column :users, :failed_login_count, :integer, :null => false, :default => 0
        add_column :users, :last_request_at, :datetime
        add_column :users, :current_login_at, :datetime
        add_column :users, :last_login_at, :datetime
        add_column :users, :current_login_ip, :string
        add_column :users, :last_login_ip, :string
    
    end

    def self.down
        remove_column :users, :crypted_password
        remove_column :users, :password_salt, :string, :null => false
        remove_column :users, :persistence_token, :string, :null => false
        remove_column :users, :single_access_token, :string, :null => false
        remove_column :users, :perishable_token, :string, :null => false
        remove_column :users, :login_count, :integer, :null => false, :default => 0
        remove_column :users, :failed_login_count, :integer, :null => false, :default => 0
        remove_column :users, :last_request_at, :datetime
        remove_column :users, :current_login_at, :datetime
        remove_column :users, :last_login_at, :datetime
        remove_column :users, :current_login_ip, :string
        remove_column :users, :last_login_ip, :string
    end
end

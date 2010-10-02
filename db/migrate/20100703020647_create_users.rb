class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email
      t.string :username
      t.integer :sex
      t.integer :age
      t.float :lat
      t.float :lng
      t.string :password
      t.integer :role_id
      t.boolean :active

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end

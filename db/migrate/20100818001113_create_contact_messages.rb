class CreateContactMessages < ActiveRecord::Migration
  def self.up
    create_table :contact_messages do |t|
      t.string :name
      t.string :email
      t.string :subject
      t.string :body
      t.integer :type

      t.timestamps
    end
  end

  def self.down
    drop_table :contact_messages
  end
end

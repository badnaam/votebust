class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.text :body
      t.status :boolean

      t.timestamps
      t.references :vote_topic, :user
    end
  end

  def self.down
    drop_table :comments
  end
end

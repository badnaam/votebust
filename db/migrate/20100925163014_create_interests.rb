class CreateInterests < ActiveRecord::Migration
  def self.up
    create_table :interests do |t|

      t.timestamps
      t.references :user
      t.references :category
    end
  end

  def self.down
    drop_table :interests
  end
end

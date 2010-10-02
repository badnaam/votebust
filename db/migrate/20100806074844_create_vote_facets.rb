class CreateVoteFacets < ActiveRecord::Migration
  def self.up
    create_table :vote_facets do |t|
      t.string :desc
      t.text :fkey
      t.references :vote_topic
      t.timestamps
    end
  end

  def self.down
    drop_table :vote_facets
  end
end

class AddCityStateToGeocodeCaches < ActiveRecord::Migration
  def self.up
    add_column :geocode_caches, :city, :string
    add_column :geocode_caches, :state, :string
  end

  def self.down
    remove_column :geocode_caches, :state
    remove_column :geocode_caches, :city
  end
end

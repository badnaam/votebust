# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
if Role.count == 0
    Role.create(:name => 'admin')
    Role.create(:name => 'user')
end
User.create(:username => 'admin', :password => 't', :password_confirmation => 't', :active => 1, :age => 34,
    :zip => 94577, :sex => 1, :email => 'admin@votechek.com', :role_id => Role.find_by_name('admin').id)
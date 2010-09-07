# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
if Role.count == 0
    Role.create(:name => APP_CONFIG['admin_role_name'])
    Role.create(:name => APP_CONFIG['user_role_name'])
end
User.create(:username => APP_CONFIG['admin_uname'], :password => APP_CONFIG['admin_pwd'], :password_confirmation => APP_CONFIG['admin_pwd'], :active => 1, :age => 34,
    :zip => 94577, :sex => 1, :email => APP_CONFIG['site_admin_email'], :role_id => Role.find_by_name(APP_CONFIG['admin_role_name']).id,
    
    :perishable_token => Authlogic::Random.friendly_token)
JobsCommon::CATEGORIES.each do |c|
    Category.create(:name => c)
end
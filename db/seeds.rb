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

u = User.new
u.username = APP_CONFIG['admin_uname']
  u.email = APP_CONFIG['site_admin_email']
  u.perishable_token = Authlogic::Random.friendly_token
  u.zip = '94577'
  u.birth_year= 1976
  u.sex = 1
  u.active = true
  u.role_id = 1
  u.password = APP_CONFIG['admin_pwd']
  u.password_confirmation = APP_CONFIG['admin_pwd']
  u.save

JobsCommon::CATEGORIES.each do |c|
    Category.create(:name => c)
end
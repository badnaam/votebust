# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
#  :key         => '_nap_on_it_session',
  :key         => '_votechek_session',
  :secret      => '91204779e481d9c74f5560135ff3e448f53be408d75486365ce2522e215ec18a1e03a3b0735413201f100d651321ffeb43af7358b1dc2bb2de506ba506d20bfc'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

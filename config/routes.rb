ActionController::Routing::Routes.draw do |map|
    map.resources :searches
    map.resources :voted_vote_topics
    # The priority is based upon order of creation: first created -> highest priority.

    # Sample of regular route:
    #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
    # Keep in mind you can assign values other than :controller and :action

    # Sample of named route:
    #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
    # This route can be invoked with purchase_url(:id => product.id)

    # Sample resource route (maps HTTP verbs to controller actions automatically):
    #   map.resources :products

    # Sample resource route with options:
    #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

    # Sample resource route with sub-resources:
    #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
    # Sample resource route with more complex sub-resources
    #   map.resources :products do |products|
    #     products.resources :comments
    #     products.resources :sales, :collection => { :recent => :get }
    #   end

    # Sample resource route within a namespace:
    #   map.namespace :admin do |admin|
    #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
    #     admin.resources :products
    #   end

    # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
    # map.root :controller => "welcome"

    # See how all your routes lay out with "rake routes"

    # Install the default routes as the lowest priority.
    # Note: These default routes make all actions in every controller accessible via GET requests. You should
    # consider removing or commenting them out if you're using named routes and resources.
    map.root :controller =>"home"
    map.with_options :controller => 'pages' do |page|
        page.about '/about', :action => 'about'
        page.faq '/faq', :action => 'faq'
        page.terms '/terms', :action => 'terms'
        page.contact '/contact', :action => 'contact'
        page.contact_receive '/contact_receive', :action => 'contact_receive', :method => :post
        page.privacy '/privacy', :action => 'privacy'
        page.disclaimer '/disclaimer', :action => 'disclaimer'
    end
    
    map.account "account", :controller => :account, :action => "index"
    map.resources :categories do |categories|
        categories.resources :vote_topics
    end
    map.resources :comments
    map.resources :graphs, :member => {:gender_graph => :get, :age_graph => :get, :pie_graph => :get}
    map.resources :vote_topics, :belongs_to => [:poster, :category], :has_many => [:comments],  :member => {:confirm_vote => :post,
        :process_votes => :post, :update_stats => :get, :cancel_vote => :post, :approve_vote => :post}, :collection => {:auto_comp => :get}
    map.resources :vote_items, :belongs_to => :vote_topic
    map.resource :user_sessions
    map.resource :account, :controller => "users"
    map.login "login", :controller =>:user_sessions, :action => "new"
    map.logout "logout", :controller =>:user_sessions, :action => "destroy"
    map.resources :password_resets
    map.sign_up "signup", :controller => "users", :action => "new"
    map.register "register/:activation_code", :controller => "activations", :action => "new"
    map.activate "activate/:id", :controller => "activations", :action => "create"
    map.addrpxauth "addrpxauth", :controller => "users", :action => "addrpxauth", :method => :post
    map.resources :users do |users|
        users.resources :posted_vote_topics, :controller => :vote_topics, :member => {:track => :post}
        users.resources :comments
        #        users.resources :roles
        #        users.resources :events
        #        users.resources :articles
        #        users.resources :comments
        #        users.resources :images
        #        users.resources :owned_merchants, :controller => :merchants
        #        users.resources :merchant_memberships
        #        users.resource :address
    end
    map.connect ':controller/:action/:id'
    map.connect ':controller/:action/:id.:format'
end

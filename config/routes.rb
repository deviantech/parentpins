ParentPins::Application.routes.draw do
  # Devise edit path redirect to profile/account edit
  match "users/edit" => redirect('/profile/edit'), :via => [:get, :post, :patch, :put]
  match "/login_first" => "front#login_first", :as => :login_first, :via => [:get, :post, :patch, :put]
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  

  resources :pins do
    member do 
      post 'like'
      post 'unlike'
      get  'success'
      get  'processed'
    end
  end

  get "/pins/:source_id/repin" => "pins#new", :as => :repin
  
  match  "/popup/pins/new"      => "popup#pin",     :as => :bookmarklet_popup, :via => [:get, :post]
  post  "/popup/pins/create"   => "popup#create",  :as => :pin_from_popup
  match  "/popup/login"        => "popup#login",   :as => :popup_login, :via => [:get, :post]
  
  # Pretty URLs for pin subtypes
  root :to => redirect { |p, req| req.flash.keep; "/pins" }
  
  get '/articles' => 'pins#index',  :kind => 'article',   :as => :articles
  get '/products' => 'pins#index',  :kind => 'product',   :as => :products
  get '/ideas'    => 'pins#index',  :kind => 'idea',      :as => :ideas

  get '/pins/category/:category_id' => 'pins#index',  :as => :pins_category

  get '/boards' => 'board#index', :as => :boards
  get '/featured' => 'featured#index', :as => :featured
    
  post '/mark/got_bookmarklet' => 'profile#got_bookmarklet'
  
  # Allow periods in URL (e.g. facebook username is kali.donovan)
  scope :profile_id => /[^\/]*/, :id => /[^\/]*/ do
    get "/profile/:profile_id/boards" => 'board#index', :as => :profile_boards
    get "/profile/:profile_id/board/:id/comments" => 'board#comments', :as => :profile_board_comments
    get "/profile/:profile_id/import/:id" => 'import#show', :as => :profile_import

    post "/profile/cover_image/remove" => 'profile#remove_generic',   :which => :cover_image,   :as => :remove_cover_image
    post "/profile/avatar/remove" => 'profile#remove_generic',        :which => :avatar,        :as => :remove_avatar    
    match "/profile/cover_image/crop" => 'profile#generic_crop',      :which => :cover_image,   :as => :crop_cover_image,     :via => [:get, :post]
    match "/profile/avatar/crop" => 'profile#generic_crop',           :which => :avatar,        :as => :crop_avatar,          :via => [:get, :post]
    
    resources :profile do
      member do
        get 'activity'
        get 'pins'
        get 'likes'
        get 'followed_by'
        get 'following'
        post 'follow'
        post 'unfollow'
      end
      resources :board do
        member do
          post 'follow'
          post 'unfollow'
          get  'edit_cover'
          patch 'update_cover'
        end
        post 'sort', :on => :collection
      end
      resource :featured, :only => [:create, :destroy], :controller => 'featured' do
        member do
          post "set_pin/:id" => "featured#set_pin", :as => :set_pin
        end
      end
    end
  end
  
  resources :comments, :only => [:create, :destroy]
  
  resource :feedback, :only => [:new, :create]
  
  get '/faq' => 'front#faq'
  get '/legal' => 'front#legal'
  get '/privacy' => 'front#privacy'
  get '/copyright' => 'front#copyright'
  get '/get/bookmarklet' => 'front#bookmarklet', :as => 'get_bookmarklet'
  
  match '/search/:kind' => 'search#index',      :via => [:get, :post]
  match '/search' => 'search#redirect_by_kind', :via => [:get, :post]

  # Use for importing pins from e.g. pinterest
  match '/import/step_1' => "import#step_1",                :as => :pin_import_step_1,        :via => [:get, :post]
  match '/import/step_2' => "import#step_2",                :as => :pin_import_step_2,        :via => [:get, :post]
  match '/import/step_3' => "import#step_3",                :as => :pin_import_step_3,        :via => [:get, :post]
  match '/import/step_4' => "import#step_4",                :as => :pin_import_step_4,        :via => [:get, :post]
  match '/import/step_5' => "import#step_5",                :as => :pin_import_step_5,        :via => [:get, :post]
  post '/import/step_5_incremental' => "import#step_5_incremental",                           :as => :pin_import_step_5_incremental
  get  '/import/step_5_incremental_completed' => "import#step_5_incremental_completed",       :as => :pin_import_step_5_incremental_completed
  match '/import/login_check' => "import#login_check",      :as => :pin_import_login_check,   :via => [:get, :post, :options]
  
  # Externally-published API
  get '/widgets/bookmarklet' => 'import#external_embedded', :as => :bookmarklet_embed

  # Internal ajax API endpoints
  get '/ajax/board/:id' => 'ajax#board'
  
  if ALLOW_MAIL_PREVIEW
    mount AdminPreview  => '/preview/mail/admin'
    mount UserPreview   => '/preview/mail/user'
  end
end

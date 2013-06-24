ParentPins::Application.routes.draw do
  # Devise edit path redirect to profile/account edit
  match "users/edit" => redirect('/profile/edit')
  match "/login_first" => "front#login_first", :as => 'login_first'
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  

  resources :pins do
    member do 
      post 'like'
      post 'unlike'
    end
  end

  get "/pins/:source_id/repin" => "pins#new", :as => 'repin'
  
  match  "/popup/pins/new"      => "popup#pin",     :as => 'bookmarklet_popup'
  match  "/popup/pins/create"   => "popup#create",  :as => 'pin_from_popup'
  match  "/popup/login"         => "popup#login",   :as => 'popup_login'
  
  # Pretty URLs for pin subtypes
  root :to => redirect("/pins")
  match '/articles' => 'pins#index',  :kind => 'article',   :as => 'articles'
  match '/products' => 'pins#index',  :kind => 'product',   :as => 'products'
  match '/ideas'    => 'pins#index',  :kind => 'idea',      :as => 'ideas'

  match '/pins/category/:category_id' => 'pins#index',  :as => 'pins_category'

  get '/boards' => 'board#index', :as => :boards
  get '/featured' => 'featured#index', :as => :featured
    
  post '/mark/got_bookmarklet' => 'profile#got_bookmarklet'
  
  # Allow periods in URL (e.g. facebook username is kali.donovan)
  scope :profile_id => /[^\/]*/, :id => /[^\/]*/ do
    get "/profile/:profile_id/boards" => 'board#index', :as => :profile_boards
    get "/profile/:profile_id/board/:id/comments" => 'board#comments', :as => :profile_board_comments
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
          put 'update_cover'
        end
        post 'sort', :on => :collection
      end
      resource :featured, :only => [:create, :destroy], :controller => 'featured' do
        member do
          post "set_pin/:id" => "featured#set_pin", :as => 'set_pin'
        end
      end
    end
  end
  
  resources :comments, :only => [:create, :destroy]
  
  resource :feedback, :only => [:new, :create]
  
  match '/faq' => 'front#faq'
  match '/legal' => 'front#legal'
  match '/privacy' => 'front#privacy'
  match '/copyright' => 'front#copyright'
  
  match '/search/:kind' => 'search#index'
  match '/search' => 'search#redirect_by_kind'

  # Use for importing pins from e.g. pinterest
  match '/import/step_1' => "import#step_1",                :as => 'pin_import_step_1'
  match '/import/step_2' => "import#step_2",                :as => 'pin_import_step_2'
  match '/import/step_3' => "import#step_3",                :as => 'pin_import_step_3'
  match '/import/step_4' => "import#step_4",                :as => 'pin_import_step_4'
  match '/import/login_check' => "import#login_check",      :as => 'pin_import_login_check'
    
  if ALLOW_MAIL_PREVIEW
    mount AdminPreview  => '/preview/mail/admin'
    mount UserPreview   => '/preview/mail/user'
  end
end

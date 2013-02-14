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
  if Rails.env.development? # TODO: remove this once styled
    match  "/popup/pins/success" => "popup#success"
  end
  
  # Pretty URLs for pin subtypes
  match '/articles' => 'pins#index',  :kind => 'article',   :as => 'articles'
  match '/products' => 'pins#index',  :kind => 'product',   :as => 'products'
  match '/ideas'    => 'pins#index',  :kind => 'idea',      :as => 'ideas'

  match '/pins/category/:category_id' => 'pins#index',  :as => 'pins_category'

  get '/boards' => 'board#index', :as => :boards
  
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
    end
  end
  
  resources :comments, :only => [:create, :destroy]
  
  
  root :to => 'pins#index'
  
  resource :feedback, :only => [:new, :create]
  
  match '/about' => 'front#about'
  match '/legal' => 'front#legal'
  match '/privacy' => 'front#privacy'
  
  match '/search/:kind' => 'search#index'
  match '/search' => 'search#redirect_by_kind'
    
  if Rails.env.development?
    mount AdminPreview  => '/preview/mail/admin'
    mount UserPreview   => '/preview/mail/user'
  end
end

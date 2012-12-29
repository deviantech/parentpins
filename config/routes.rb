ParentPins::Application.routes.draw do
  devise_for :users

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  resources :boards
  resources :pins, :except => [:show]

  # Pretty URLs for pin subtypes
  match '/articles' => 'pins#index',  :kind => 'article',   :as => 'articles'
  match '/gifts'    => 'pins#index',  :kind => 'gift',      :as => 'gifts'
  match '/ideas'    => 'pins#index',  :kind => 'idea',      :as => 'ideas'
  
  resources :profiles do
    member do
      get 'activity'
      get 'pins'
      get 'likes'
      get 'boards'
      get 'followers'
      get 'following'
      get 'boards/:board_id' => 'profiles#board', :as => 'board'
    end    
  end

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end


  root :to => 'static#index'
  match ':action' => 'static#'

  # See how all your routes lay out with "rake routes"
end

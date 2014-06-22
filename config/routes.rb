Rails.application.routes.draw do



  root 'containers#index'

  get  'images/index'
  post 'images/:id/delete'   , :to => 'images#delete', :as => 'image_delete', :constraints => { :id => /[^\#]+/ }
  post 'images/:id/create'   , :to => 'images#create', :as => 'image_create', :constraints => { :id => /[^\#]+/ }
  get  'images/remote_images', :to => 'images#remote_images'

  get  'containers/index'
  post 'containers/:id/start'   , :to => 'containers#start' , :as => 'container_start'
  post 'containers/:id/stop'    , :to => 'containers#stop'  , :as => 'container_stop'
  post 'containers/:id/kill'    , :to => 'containers#kill'  , :as => 'container_kill'
  post 'containers/:id/delete'  , :to => 'containers#delete', :as => 'container_delete'
  post 'containers/:id/create'  , :to => 'containers#create', :as => 'container_create', :constraints => { :id => /[^\#]+/ }


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

Mesafija::Application.routes.draw do
  resources :api_mesafijas
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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

  get '/getID' => 'api_mesafijas#getID'
  get '/init' => 'api_mesafijas#init'
  get '/rest_lista' => 'api_mesafijas#rest_lista'
  get '/rest_datos' => 'api_mesafijas#rest_datos'
  get '/rest_disponibilidad_calendario' => 'api_mesafijas#rest_disponibilidad_calendario'
  get '/rest_disponibilidad_rango_plazas' => 'api_mesafijas#rest_disponibilidad_rango_plazas'
  get '/rest_disponibilidad_horas_disponibles' => 'api_mesafijas#rest_disponibilidad_horas_disponibles'
  get '/rest_disponibilidad_turno_disponibles' => 'api_mesafijas#rest_disponibilidad_turno_disponibles'
  get '/rest_reserva_agregar' => 'api_mesafijas#rest_reserva_agregar'
  get '/rest_reserva_cancelar' => 'api_mesafijas#rest_reserva_cancelar'
  get '/usuario_login' => 'api_mesafijas#usuario_login'
  get '/usuario_regpswd' => 'api_mesafijas#usuario_regpswd'
  get '/usuario_registro' => 'api_mesafijas#usuario_registro'
  get '/usuario_datos' => 'api_mesafijas#usuario_datos'
  get '/usuario_editar' => 'api_mesafijas#usuario_editar'
  get '/valoracion' => 'api_mesafijas#valoracion'
  get '/usuario_favorito_agregar' => 'api_mesafijas#usuario_favorito_agregar'
  get '/usuario_favorito_eliminar' => 'api_mesafijas#usuario_favorito_eliminar'
  get '/preguntas' => 'api_mesafijas#preguntas'
end

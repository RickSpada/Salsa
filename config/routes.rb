Salsa::Application.routes.draw do
  # the 'lines' endpoint, define only for 'index'
  resources :lines, only: [:index]
  resource :file, only: [:create], controller: 'file'
end

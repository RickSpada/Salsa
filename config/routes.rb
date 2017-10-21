Salsa::Application.routes.draw do
  # the 'lines' endpoint, define only for 'index'
  resources :lines, only: [:index]
end

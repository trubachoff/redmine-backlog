# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html


resources :backlogs do
  get :backlogs, :to => 'backlogs#index'
  post :update_row_order, on: :collection
end


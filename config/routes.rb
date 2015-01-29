Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  get '/' => 'application#index'
  get 'application/basic_info' => 'application#basic_info'
  post 'application/basic_info' => 'application#basic_info_submit'
  get 'application/contact_info' => 'application#contact_info'
  post 'application/contact_info_submit' => 'application#contact_info_submit'
  get 'application/sex_and_ssn' => 'application#sex_and_ssn'
  post 'application/sex_and_ssn' => 'application#sex_and_ssn_submit'
  get 'application/medical' => 'application#medical'
  post 'application/medical_submit' => 'application#medical_submit'
  get 'application/interview' => 'application#interview'
  post 'application/interview_submit' => 'application#interview_submit'
  get 'application/household_question' => 'application#household_question'
  get 'application/additional_household_member' => 'application#additional_household_member'
  post 'application/additional_household_member_submit' => 'application#additional_household_member_submit'
  get 'application/review_and_submit' => 'application#review_and_submit'

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

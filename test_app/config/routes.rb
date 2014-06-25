Rails.application.routes.draw do

  get 'test_form/index'

  mount FormsJinny::Engine => "/forms_jinny"
end

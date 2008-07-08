ActionController::Routing::Routes.draw do |map|

  map.resources :calls, :collection => { :history   => :get,
                                         :behaviour => :get }
  map.root :calls

end

ActionController::Routing::Routes.draw do |map|

  map.with_options :controller => 'calls' do |route|
    route.calls          '',                  :action => 'index', :conditions => { :method => :get }
    route.calls          '',                  :action => 'create', :conditions => { :method => :post }
    route.call_history   'call-history',      :action => 'history', :conditions => { :method => :get }
    route.call_behaviour 'call-behaviour.js', :action => 'behaviour', :format => :js, :conditions => { :method => :get }
  end

end

# fix gettext for Rails 2.1 (from http://zargony.com/2008/02/12/edge-rails-and-gettext-undefined-method-file_exists-nomethoderror)
module ActionView
  class Base
    delegate :file_exists?, :to => :finder unless respond_to?(:file_exists?)
  end
end

# include Date l18n
require 'gettext_date'

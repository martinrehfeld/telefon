# 
# gettext_date.rb
# 
# Created on 19/10/2007, 12:39:52 by Sam Lown <dev at samlown dot com>
# 
# Methods designed to extend the normal Time and Date classes to provide
# internationlized month and day names
# 
# How to test in console (mainly for my reference!):
# 
#  include GetText
#  bindtextdomain("SGCMS", :path => File.join(RAILS_ROOT, 'locale'))
#  set_locale 'es_ES'
#
 

module GettextDate
  
  class Conversions
    
    class << self
      
      def standard_date_formats( code )
        case code
        when 'F'
          _('%Y-%m-%d')
        when 'c'
          _('%a %b %e %H:%M:%S %Y')
        when 'D'
          _('%m/%d/%y')
        end
      end
      
      def daynames( index )
        [ _('Sunday'), _('Monday'), _('Tuesday'), _('Wednesday'),
          _('Thursday'), _('Friday'), _('Saturday') ].at(index)
      end
      
      def abbr_daynames( index )
        [ _('Sun'), _('Mon'), _('Tue'), _('Wed'),
          _('Thu'), _('Fri'), _('Sat') ].at(index)
      end
      
      def monthnames( index )
        [ nil, _('January'), _('February'), _('March'), _('April'), 
          _('May'), _('June'), _('July'), _('August'), _('September'), 
          _('October'), _('November'), _('December')
        ].at( index )
      end
      
      def abbr_monthnames( index )
        [ nil, _('Jan'), _('Feb'), _('Mar'), _('Apr'), _('May'), _('Jun'),
          _('Jul'), _('Aug'), _('Sep'), _('Oct'),
          _('Nov'), _('Dec')
        ].at( index )
      end
      
      def meridies( hour, upper_case = false )
        if hour < 12
          (upper_case ? _('AM') : _('am'))
        else
          (upper_case ? _('PM') : _('pm'))
        end
      end
      
    end
    
  end
  
  module Extensions
    
    def self.included( mod )
      mod.send(:alias_method, :strftime_default, :strftime)
      mod.send(:alias_method, :strftime, :strftime_localised)
    end
    #
    # Replaces the standard #strftime, but returns a localized version of the formatted date string.
    # Requires the stftime_basic method to exist!
    #
    # Options:
    # 
    #  * +format+ - A string with strftime codes. See Ruby stdlibs.
    #  * +skip_international+ - if true, skip localising the string and provide
    # a version in english. This is useful for RFC formats and ISOs.
    #
    def strftime_localised( format = '%F', skip_international = false )
      # unabashedly stolen from Globalite, which unabashedly stole from Globalize,
      # which unabashedly stole this snippet from Tadayoshi Funaba's Date class
      # and was changed by Sam Lown

      if ! skip_international  
        convs = GettextDate::Conversions
        o = ''
        r = false
        format.scan(/%[EO]?.|./o) do |c|
          cc = c.sub(/^%[EO]?(.)$/o, '%\\1')
          case cc
          when '%F'; o << convs.standard_date_formats( 'F' ); r = true
          when '%c'; o << convs.standard_date_formats( 'c' ); r = true
          when '%D'; o << convs.standard_date_formats( 'D' ); r = true
          when '%A'; o << convs.daynames( wday )
          when '%a'; o << convs.abbr_daynames( wday )
          when '%B'; o << convs.monthnames( mon )
          when '%b'; o << convs.abbr_monthnames( mon )
          when '%P'; o << convs.meridies( hour, true )
          when '%p'; o << convs.meridies( hour, false )
          else;      o << c
          end
        end

        # if string contains localised parts, re-run this call
        o = strftime_localised( o ) if r
      else
        o = format
      end

      strftime_default( o )
    end    
  
  end
  
  # Extra methods for the Time class which requires a little but more manipulation
  # especially for the version modified by Rails.
  module TimeExtensions
    
    def self.included mod
      # The following (messy looking) calls setup the aliases so that the default
      # time formating calls will use the internationalised versions.
      mod.send(:alias_method, :to_rails_formatted_s, :to_formatted_s) # if mod.respond_to?(:to_formatted_s)
      mod.send(:alias_method, :to_formatted_s, :to_localised_formatted_s)
      mod.send(:alias_method, :to_s, :to_localised_formatted_s)
      mod.send(:alias_method, :to_old_default_s, :to_default_s)
      mod.send(:alias_method, :to_default_s, :to_localised_default_s)
    end
    
    def to_localised_default_s
      strftime('%a %b %d %H:%M:%S %Z %Y')
    end
    
    #
    # Overwrite the normal to_formatted_s created by rails, with a version
    # that will ignore rfc and iso dates, producing them in normal english
    #
    # This code is copied directly from Rails, hopefully it won't change any time
    # soon! (2007-10-31)
    #
    def to_localised_formatted_s( format = :default )
      skip_international = ( format.to_s =~ /^rfc|iso/ )
      if formatter = ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS[format]
        if formatter.respond_to?(:call)
          formatter.call(self).to_s
        else
          strftime(formatter, skip_international).strip
        end
      else
        to_default_s
      end
    end  
  end
  
  module ActionControllerExtensions
    
    def self.included mod
      mod.extend( ClassMethods )
      mod.class_eval do
        class << self
          alias_method :init_gettext_original, :init_gettext
          alias_method :init_gettext, :init_gettext_with_dates
        end
      end
    end
    
    module ClassMethods
      def init_gettext_with_dates(domainname, options = {}, content_type = "text/html")
        init_gettext_original(domainname, options, content_type)
        textdomain_to( GettextDate::Conversions, domainname ) if defined? GettextDate::Conversions
      end
    end
  end

end

# Overwrite the standard strftime date method
Date.class_eval do
  include GettextDate::Extensions
end

Time.class_eval do
  include GettextDate::Extensions
  include GettextDate::TimeExtensions
end

ActionController::Base.class_eval do
  include GettextDate::ActionControllerExtensions
end


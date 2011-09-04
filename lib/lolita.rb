
$:<<File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))
LOLITA_VERSION=File.read(File.expand_path("../../VERSION",__FILE__)).gsub(/[^.\w]/,"")
puts "=> Lolita #{LOLITA_VERSION} starting#{defined?(Rails) ? " with Rails" : ""}"

# TODO should allow run lolita seperated
# unless (["-d","--debug"] & ARGV).empty?
#   require "ruby-debug"
#   Debugger.settings[:autoeval]=true
# else
#   unless self.respond_to?(:debugger)
#     def debugger
#       warn "Debugger called at #{caller.first} was ignored, run lolita with -d to attatch debugger."
#     end
#   end
# end

require 'abstract'
require "base64"
unless defined?(ActiveSupport)
  require 'active_support/core_ext/numeric/time'
  require 'active_support/core_ext/date_time/conversions'
  require 'active_support/concern'
  require 'active_support/callbacks'
  require 'active_support/dependencies'
end
require 'lolita/errors'
require "lolita/hooks"
# Require all ruby extensions
Dir["#{File.dirname(__FILE__)}/lolita/ruby_ext/**/*.*"].each do |path|
  require path
end

module Lolita
  include Lolita::Hooks
  add_hook :before_setup, :after_setup, :after_routes_loaded,:before_routes_loaded
  
  autoload(:LazyLoader,'lolita/lazy_loader')
  autoload(:VERSION,'lolita/version')
  autoload(:ObservedArray,'lolita/observed_array')
  autoload(:Builder,'lolita/builder')
  module Builder
    autoload(:Custom, 'lolita/builder')
  end

  module SystemConfiguration
    autoload :Base, 'lolita/system_configuration/base'
    autoload :Application, 'lolita/system_configuration/application'
  end

  module Adapter
    autoload :AbstractAdapter, 'lolita/adapter/abstract_adapter'
    autoload :ActiveRecord, 'lolita/adapter/active_record'
    autoload :Mongoid, 'lolita/adapter/mongoid'
  end

  module DBI
    autoload :Base, 'lolita/dbi/base'
  end
  
  module Hooks
    autoload :NamedHook, "lolita/hooks/named_hook"
  end
 

  module Configuration
    autoload :Helper, 'lolita/configuration/helper'
    autoload :Base, 'lolita/configuration/base'
    autoload :Column, 'lolita/configuration/column'
    autoload :Columns, 'lolita/configuration/columns'
    autoload :Fields, 'lolita/configuration/fields'
    autoload :FieldSet, 'lolita/configuration/field_set'
    autoload :List, 'lolita/configuration/list'
    autoload :Tabs, 'lolita/configuration/tabs'
    autoload :Filter, 'lolita/configuration/filter'
    autoload :NestedForm, 'lolita/configuration/nested_form'

    module Factory
      autoload :Field, "lolita/configuration/factory/field"
      autoload :Tab, "lolita/configuration/factory/tab"
    end

    
    module Field
      autoload :Base,'lolita/configuration/field'
      Dir["#{File.dirname(__FILE__)}/lolita/configuration/field/**/*.*"].each do |path|
        base_name=File.basename(path,".rb")
        autoload :"#{base_name.camelize}", "lolita/configuration/field/#{base_name}"
      end
    end

    module Tab
      autoload :Base, 'lolita/configuration/tab'
      ["tab"].each do |type|
        Dir["#{File.dirname(__FILE__)}/lolita/configuration/#{type}/**/*.*"].each do |path|
          base_name=File.basename(path,".rb")
          autoload :"#{base_name.camelize}", "lolita/configuration/#{type}/#{base_name}"
        end
      end
    end
    
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        def lolita
          self.class.lolita
        end
      end
    end

    module ClassMethods
      def lolita(&block)
        Lolita::LazyLoader.lazy_load(self,:@lolita,Lolita::Configuration::Base,self,&block)
      end
      def lolita=(value)
        if value.is_a?(Lolita::Configuration::Base)
          @lolita=value
        else
          raise ArgumentError.new("Only Lolita::Configuration::Base is acceptable.")
        end
      end
    end
  end

  module Test
    autoload :Matchers, 'lolita/test/matchers'
  end
  
  module Controllers
    autoload :InternalHelpers, 'lolita/controllers/internal_helpers'
    autoload :UserHelpers, 'lolita/controllers/user_helpers'
    autoload :UrlHelpers, 'lolita/controllers/url_helpers'
    autoload :ComponentHelpers, 'lolita/controllers/component_helpers'
    autoload :ViewUserHelpers, 'lolita/controllers/view_user_helpers'
  end

  module Navigation
    autoload :Tree, "lolita/navigation/tree"
    autoload :Branch, "lolita/navigation/branch"
  end

  module Support
    autoload :Formatter, 'lolita/support/formatter'
    class Formatter
      autoload :Rails, 'lolita/support/formatter/rails'
    end
  end

  @@scopes={}

  def self.scope name=nil
    name||=scope_name
    @@scopes[name]||=Lolita::SystemConfiguration::Base.new(name)
    @@scopes[name]
  end

  def self.setup
    self.run(:before_setup)
    yield scope
    self.run(:after_setup)
  end

  def self.scope_name
    :default
  end
  
  def self.root
    @@root||=File.expand_path("#{__FILE__}/../..")
  end

  def self.app_root
    @@app_root||=File.join(File.expand_path("#{__FILE__}/../.."),"app")
  end
  
  def self.method_missing method_name, *args, &block
    scope.send(method_name,*args,&block)
  end

  def self.rails3?
    defined?(::Rails) && ::Rails::VERSION::MAJOR == 3
  end

  module Generators
    autoload :FileHelper, File.join(Lolita.root,"lib","generators","helpers","file_helper")
  end
  
end

if Lolita.rails3?
  require 'lolita/rails/all'
end

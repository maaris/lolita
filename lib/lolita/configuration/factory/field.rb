module Lolita
  module Configuration
    module Factory
      class Field
        # There are three ways to add field.
        # *<tt>first</tt> - Pass name and type
        #   Field.add(dbi,"name","type")
        # *<tt>second</tt> - Pass it through hash
        #   Field.add(dbi,:name => "name", :type => "type")
        # *<tt>third</tt> - Pass dbi_field
        #   Field.add(dbi,:dbi_field => dbi.fields.first)
        def self.add(dbi,*args,&block)
      
          options = args ? args.extract_options! : {}
          dbi_field = options[:dbi_field]
          name = args[0] || options[:name] || (dbi_field ? dbi_field.name : nil)
          dbi_field ||= dbi.field_by_name(name)
          type = args[1] || options[:type] || (dbi_field ? dbi_field.type : nil)
          options[:dbi_field] = dbi_field

          if !name || !type
            raise Lolita::FieldTypeError, "type not defined. Set is as second argument or as :dbi_field where value is Adapter::[ORM]::Field object."
          else
            field_class(type).new(dbi,name,type,options,&block)
          end

        end

        def self.field_class(name)
          ("Lolita::Configuration::Field::"+name.to_s.camelize).constantize
        end
      end
    end
  end
end
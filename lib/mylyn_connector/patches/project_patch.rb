module MylynConnector

  module Patches

    module ProjectPatch

      def self.included(base) # :nodoc:
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
        end

      end

      module ClassMethods

        #packport of Project.visible_condition
        def visible_condition(user)
            visible_by(user)
        end

      end

      module InstanceMethods
      end
      
    end

  end

end

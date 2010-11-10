# Every adapter need to include this module to be sure that every method
# needed for Lolita is defined in adapter.
module Lolita
  module Adapter
    module AbstractAdapter
      def fields
        raise_err
      end

      def paginate(options={})
        raise_err
      end

      private

      def raise_err
        raise "You must implement this method!"
      end
    end
  end
end
module SimpleBackup
  module Source
    class Abstract
      def configure(*args)
        raise NotImplementedError
      end

      def type
        self.class.name.split('::').last
      end

      def desc
        raise NotImplementedError
      end

      def keep_last=(value)
        @keep_last = value
      end
    end
  end
end

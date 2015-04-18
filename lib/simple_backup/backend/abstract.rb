module SimpleBackup
  module Backend
    class Abstract
      @@logger = Utils::Logger.instance

      def configure(*args)
        raise NotImplementedError
      end

      def name=(value)
        @name = value.gsub(/[^a-zA-Z0-9\-\_\. ]*/, '').gsub(/\s+/, '_').downcase
      end

      def name
        @name
      end

      def type
        self.class.name.split('::').last.gsub(/[^a-zA-Z0-9\-\_\. ]*/, '').gsub(/\s+/, '_').downcase
      end

      def desc
        '%5s :: %s' % [type, @name]
      end

      def store(source)
        raise NotImplementedError
      end

      def cleanup(source)
        raise NotImplementedError
      end
    end
  end
end

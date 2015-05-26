module SimpleBackup
  module Backend
    class Abstract
      attr_writer :logger

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

      private

      def logger
        Utils::Logger.instance unless @logger
        @logger if @logger
      end
    end
  end
end

module SimpleBackup
  module Utils
    class MockOutput
      attr_reader :buffer

      def puts(message)
        @buffer = [] unless @buffer
        @buffer << message
      end
    end

    class Logger
      attr_reader :scope

      def self.clear_instances
        @_instance = nil
      end

      def clear_buffer
        @buffer = []
      end
    end

    describe Logger do
      it 'should add banner after initialization' do
        output = MockOutput.new
        get_logger(output)

        expect(output.buffer.length).to be > 0
      end

      it 'should return buffer' do
        logger = get_logger
        buffer = logger.buffer

        expect(buffer).to  be_instance_of(Array)
        expect(buffer.length).to be > 0
      end

      it 'should provide debug loging methods' do
        logger = get_logger
        logger.debug('message')
      end

      it 'should provide info loging methods' do
        logger = get_logger
        logger.info('message')
      end

      it 'should provide warning loging methods' do
        logger = get_logger
        logger.warning('message')
      end

      it 'should provide error loging methods' do
        logger = get_logger
        logger.error('message')
      end

      it 'should add timestamp and level info into log line' do
        logger = get_logger
        logger.clear_buffer
        logger.log(:error, "Test message")

        expect(logger.buffer.first).to match(/[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\s+ERROR:\s+Test message/)
      end

      it 'should give the ability to change the logging scope' do
        logger = get_logger
        old_scope = logger.scope 
        logger.scope_start
        added_scope = logger.scope
        logger.scope_end
        removed_scope = logger.scope

        expect(added_scope).to be > old_scope
        expect(removed_scope).to be < added_scope
        expect(removed_scope).to eq(old_scope)
      end

      context 'when valid level is used' do
        it 'should give the ability to change the minimum display level' do
          logger = get_logger
          old_level = logger.level
          logger.level = :debug
          new_level = logger.level

          expect(old_level).not_to eq(new_level)
        end
      end

      context 'when invalid level is used' do
        it 'should raise an exception when trying to change the minimum display level' do
          logger = get_logger
          expect { logger.level = :unknown }.to raise_error(RuntimeError, "Unknown logging level unknown")
        end

        it 'should raise an exception when trying to log message' do
          logger = get_logger
          expect { logger.log(:unknown, "message") }.to raise_error(RuntimeError, "Unknown logging level unknown")
        end
      end

      def get_logger(output = StringIO.new)
        Logger.clear_instances
        logger = Logger.instance(output)
        logger
      end
    end
  end
end


require 'singleton'

module SimpleBackup
  # Version class
  #
  class Version
    include Singleton

    MAJOR = 0
    MINOR = 5
    PATCH = 0
    PRE_RELEASE = 'dev'

    def get
      version = "#{MAJOR}.#{MINOR}.#{PATCH}"
      version += "-#{format(PRE_RELEASE)}" unless PRE_RELEASE.nil?

      version
    end

    private

    def format(value)
      value.gsub(/a-zA-Z0-9\_ /, '').gsub(' ', '_').downcase
    end
  end
end

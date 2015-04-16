module SimpleBackup
  class Version
    MAJOR = 0
    MINOR = 2
    PATCH = 1
    PRE_RELEASE = nil

    def self.get
      version = "#{MAJOR}.#{MINOR}.#{PATCH}"
      version += "-#{self.format(PRE_RELEASE)}" unless PRE_RELEASE.nil?

      version
    end

    def self.format(value)
      value.gsub(/a-zA-Z0-9\_ /, '').gsub(' ', '_').downcase
    end
  end
end

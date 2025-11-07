module RedCloth
  module VERSION
    MAJOR = 4
    MINOR = 3
    TINY  = 4
#    RELEASE_CANDIDATE = 0

    STRING = [MAJOR, MINOR, TINY].compact.join('.')
    TAG = "REL_#{[MAJOR, MINOR, TINY].compact.join('_')}".upcase.gsub(/\.|-/, '_')
    FULL_VERSION = "#{[MAJOR, MINOR, TINY].compact.join('.')}"
    
    class << self
      def to_s
        STRING
      end
      
      def ==(arg)
        STRING == arg
      end
    end
  end
  
  NAME = "RedCloth"
  GEM_NAME = NAME
  URL  = "https://github.com/jgarber/redcloth"
  description = "Textile parser for Ruby."

  if RedCloth.const_defined?(:EXTENSION_LANGUAGE)
    SUMMARY = "#{NAME}-#{VERSION::FULL_VERSION}-#{EXTENSION_LANGUAGE}"
  else
    SUMMARY = "#{NAME}-#{VERSION::FULL_VERSION}"
  end
  DESCRIPTION = SUMMARY + " - #{description}\n#{URL}"
end

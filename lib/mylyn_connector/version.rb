module MylynConnector
  module Version
    MAJOR = 2
    MINOR = 7
    TINY  = 6

    # stable/trunk
    BRANCH = 'stable'

    def self.revision
      return nil
    end

    REVISION = self.revision

    ARRAY = [MAJOR, MINOR, TINY, BRANCH, REVISION].compact
    STRING = ARRAY.join('.')

    REDMINE = Redmine::VERSION.to_a.slice(0,2).join('.')
    
    def self.to_a; ARRAY end
    def self.to_s; STRING end
    def self.redmine_release; REDMINE end

    module ClassMethods

      def is1dot0?
        MylynConnector::Version.redmine_release.to_f == 1.0 || MylynConnector::Version.redmine_release.to_f == 0.9 && Redmine::VERSION.to_s.include?('devel')
      end

      def is1dot1?
        MylynConnector::Version.redmine_release.to_f == 1.1 || MylynConnector::Version.redmine_release.to_f == 1.0 && Redmine::VERSION.to_s.include?('devel')
      end

      def is1dot2?
        MylynConnector::Version.redmine_release.to_f == 1.2 || MylynConnector::Version.redmine_release.to_f == 1.1 && Redmine::VERSION.to_s.include?('devel')
      end

      def isMin1dot2?
        MylynConnector::Version.redmine_release.to_f >= 1.2 || MylynConnector::Version.redmine_release.to_f == 1.1 && Redmine::VERSION.to_s.include?('devel')
      end
    end

  end
end

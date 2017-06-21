require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting redmine-mylyn-connector plugin for Redmine'

Redmine::Plugin.register :redmine_mylyn_connector do
  name 'Mylyn Connector plugin'
  author 'Sven Krzyzak'
  description 'This plugin provides a webservice API for Eclipse Mylyn (RESTful)'
  version MylynConnector::Version
end

Redmine::Plugin.find(:redmine_mylyn_connector).requires_redmine(:version_or_higher=>'1.0.0')

require_dependency 'mylyn_connector/hooks/controller_issues_edit_after_save'

require 'dispatcher'
require 'mylyn_connector/patches/custom_value_patch'
Dispatcher.to_prepare do
  CustomValue.send(:include, MylynConnector::Patches::CustomValuePatch) unless CustomValue.included_modules.include?(MylynConnector::Patches::CustomValuePatch)
end

#Redmine::VERSION.to_a.slice(0,2).join('.')

if MylynConnector::Version.redmine_release.to_f < 1.2
  require 'mylyn_connector/patches/project_patch'
  Dispatcher.to_prepare do
    Project.send(:include, MylynConnector::Patches::ProjectPatch) unless Project.included_modules.include?(MylynConnector::Patches::ProjectPatch)
  end
end

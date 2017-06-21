require File.dirname(__FILE__) + '/../../../lib/mylyn_connector'

class MylynConnector::ProjectsController < MylynConnector::ApplicationController
  unloadable
  include MylynConnector::Rescue::ClassMethods

  accept_api_auth :all
  
  skip_before_filter :verify_authenticity_token

  helper MylynConnector::MylynHelper

  def all
    @projects = Project.find(:all,
      :joins => :enabled_modules,
      :conditions => [ "enabled_modules.name = 'issue_tracking' AND #{Project.visible_condition(User.current)}"])

    respond_to do |format|
      format.xml {render :layout => false}
    end
  end
  
end

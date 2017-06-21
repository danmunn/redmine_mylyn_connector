require File.dirname(__FILE__) + '/../../../lib/mylyn_connector'

class MylynConnector::QueriesController < MylynConnector::ApplicationController
  unloadable
  include MylynConnector::Rescue::ClassMethods

  accept_api_auth :all
  
  skip_before_filter :verify_authenticity_token

  helper MylynConnector::MylynHelper

  def all

    @queries = Query.find(
      :all,
      :joins => ["left join #{Project.table_name} on project_id=#{Project.table_name}.id"],
      :conditions => ["(#{Query.table_name}.is_public = ? OR #{Query.table_name}.user_id = ?) AND (project_id IS NULL OR "  << Project.visible_condition(User.current) << ")", true, User.current.id],
      :order => "#{Query.table_name}.name ASC"
    )

    respond_to do |format|
      format.xml {render :layout => false}
    end
  end
end

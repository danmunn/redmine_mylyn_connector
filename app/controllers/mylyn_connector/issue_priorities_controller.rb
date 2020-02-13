require File.dirname(__FILE__) + '/../../../lib/mylyn_connector'

class MylynConnector::IssuePrioritiesController < MylynConnector::ApplicationController
  unloadable

  accept_api_auth :all
  skip_before_action :verify_authenticity_token
  helper MylynConnector::MylynHelper

  def all
    @priorities  = IssuePriority.shared.active;

    respond_to do |format|
      format.xml {render :layout => nil}
    end
  end

end

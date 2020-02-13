require File.dirname(__FILE__) + '/../../../lib/mylyn_connector'

class MylynConnector::TimeEntryActivitiesController < MylynConnector::ApplicationController
  unloadable

  accept_api_auth :all
  skip_before_action :verify_authenticity_token
  helper MylynConnector::MylynHelper

  def all
    @activities = TimeEntryActivity.shared.active

    respond_to do |format|
      format.xml {render :layout => nil}
    end
  end

end

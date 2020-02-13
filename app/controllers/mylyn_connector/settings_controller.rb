require File.dirname(__FILE__) + '/../../../lib/mylyn_connector'

class MylynConnector::SettingsController < MylynConnector::ApplicationController
  unloadable

  accept_api_auth :all
  skip_before_action :verify_authenticity_token
  helper MylynConnector::MylynHelper

  def all
    @settings = Setting

    respond_to do |format|
      format.xml {render :layout => nil}
    end
  end
end

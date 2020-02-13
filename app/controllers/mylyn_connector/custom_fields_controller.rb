require File.dirname(__FILE__) + '/../../../lib/mylyn_connector'

class MylynConnector::CustomFieldsController < MylynConnector::ApplicationController
  unloadable

  accept_api_auth :all
  skip_before_action :verify_authenticity_token
  helper MylynConnector::MylynHelper

  def all
    @custom_fields = CustomField.all

    respond_to do |format|
      format.xml {render :layout => nil}
    end
  end

end

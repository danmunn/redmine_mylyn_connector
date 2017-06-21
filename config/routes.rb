ActionController::Routing::Routes.draw do |map|

  map.with_options :format => 'xml', :conditions => {:method => :get} do |rmc|
    #meta / settings
    rmc.connect "mylyn/settings", :controller => "MylynConnector::Settings", :action => "all"
    rmc.connect "mylyn/version", :controller => "MylynConnector::Information", :action => "version"
    rmc.connect "mylyn/token", :controller => "MylynConnector::Information", :action => "token"

    #attributes
    rmc.connect "mylyn/customfields", :controller => "MylynConnector::CustomFields", :action => "all"
    rmc.connect "mylyn/issuecategories", :controller => "MylynConnector::IssueCategories", :action => "all"
    rmc.connect "mylyn/issuepriorities", :controller => "MylynConnector::IssuePriorities", :action => "all"
    rmc.connect "mylyn/versions", :controller => "MylynConnector::Versions", :action => "all"
    rmc.connect "mylyn/queries", :controller => "MylynConnector::Queries", :action => "all"
    rmc.connect "mylyn/users", :controller => "MylynConnector::Users", :action => "all"
    rmc.connect "mylyn/timeentryactivities", :controller => "MylynConnector::TimeEntryActivities", :action => "all"
    rmc.connect "mylyn/trackers", :controller => "MylynConnector::Trackers", :action => "all"
    rmc.connect "mylyn/issuestatus", :controller => "MylynConnector::IssueStatus", :action => "all"

    #projects
    rmc.connect "mylyn/projects", :controller => "MylynConnector::Projects", :action => "all"

#  map.connect "mylyn/:project_id/search", :controller => "MylynConnector::Issues", :action => "query"
#  map.connect "mylyn/search", :controller => "MylynConnector::Issues", :action => "query"
    rmc.connect "mylyn/issue/:id", :controller => "MylynConnector::Issues", :action => "show"
    rmc.connect "mylyn/issues/updatedsince", :controller => "MylynConnector::Issues", :action => "updated_since"
    rmc.connect "mylyn/issues/list", :controller => "MylynConnector::Issues", :action => "list"
    rmc.connect "mylyn/issues", :controller => "MylynConnector::Issues", :action => "index"

    #very dirty workaround: enables REST-Api-Auth for attachments
    rmc.connect 'mylyn/attachment/:id/:filename', :controller => 'attachments', :action => 'download', :format=> 'xml', :id => /\d+/, :filename => /.*/
  end

  map.connect 'mylyn/authtest', :controller => 'MylynConnector::Information', :action => 'authtest', :format=> 'xml', :conditions => {:method => :get}

end

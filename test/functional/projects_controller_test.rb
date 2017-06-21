require File.dirname(__FILE__) + '/../test_helper'

class MylynConnector::ProjectsControllerTest < MylynConnector::ControllerTest

  fixtures :users, :roles, :members, :member_roles, :issue_categories, :custom_fields, :trackers, :versions, :queries, :projects, :projects_trackers, :enabled_modules, :custom_fields_trackers, :enumerations


  def setup
    super
    @controller = MylynConnector::ProjectsController.new
  end

  def test_all_unauthenticated
    get :all
    assert_response :success
    assert_template 'all.xml.builder'

    xmldoc = XML::Document.string @response.body
    schema = read_schema 'projects'
    valid = xmldoc.validate_schema schema
    assert valid , 'Ergenis passt nicht zum Schema ' + 'projects'

    prjs =  {:tag => 'projects', :children => {:count => 2}, :attributes => {:api => cr}}
    p1 = {:tag => 'project', :attributes => {:id => 1, :newissueallowed => "false", :moveissueallowed => "false"}, :parent => prjs}
    p3 = {:tag => 'project', :attributes => {:id => 3, :newissueallowed => "false", :moveissueallowed => "false"}, :parent => prjs}

    assert_tag prjs
    assert_tag p1
    assert_tag p3
    
    assert_tag :tag => 'name', :content => 'eCookbook', :parent => p1
    assert_tag :tag => 'identifier', :content => 'ecookbook', :parent => p1

    assert_tag :tag => 'trackers', :content => '1 2 3', :parent => p1
    assert_tag :tag => 'trackers', :content => '2 3', :parent => p3

    assert_tag :tag => 'versions', :content => '1 2 3 4 6 7', :parent => p1
    assert_tag :tag => 'versions', :content => '4 6 7', :parent => p3

    m1 = {:tag => 'members', :children => {:count => 2}, :parent => p1}
    assert_tag :tag => 'member', :attributes => {:userid => 2, :assignable => 'true'}, :parent => m1
    assert_tag :tag => 'member', :attributes => {:userid => 3, :assignable => 'true'}, :parent => m1
    assert_tag :tag => 'members', :children => {:count => 0}, :parent => p3

    assert_tag :tag => 'issuecategories', :content => '1 2', :parent => p1
    assert_tag :tag => 'issuecategories', :content => '', :parent => p3

    assert_tag :tag => 'issuecustomfieldsbytracker', :content => '1 2 6', :attributes => {:trackerid => 1}, :parent => {:tag => 'issuecustomfields', :children => {:count => 3}, :parent => p1}
    assert_tag :tag => 'issuecustomfieldsbytracker', :content => '6', :attributes => {:trackerid => 2}, :parent => {:tag => 'issuecustomfields', :children => {:count => 3}, :parent => p1}
    assert_tag :tag => 'issuecustomfieldsbytracker', :content => '2 6', :attributes => {:trackerid => 3}, :parent => {:tag => 'issuecustomfields', :children => {:count => 3}, :parent => p1}

    assert_tag :tag => 'issuecustomfieldsbytracker', :content => '6', :attributes => {:trackerid => 2}, :parent => {:tag => 'issuecustomfields', :children => {:count => 2}, :parent => p3}
    assert_tag :tag => 'issuecustomfieldsbytracker', :content => '2 6', :attributes => {:trackerid => 3}, :parent => {:tag => 'issuecustomfields', :children => {:count => 2}, :parent => p3}

    acts =  {:tag => 'timeentryactivities', :children => {:count => 2}, :parent=>p1}
    act = {:tag => 'timeentryactivity', :attributes => {:id => 999}, :parent => acts}
    assert_tag :tag => 'name', :content => 'Development', :parent => act
    assert_tag :tag => 'position', :content => '5', :parent => act
    assert_tag :tag => 'isdefault', :content => 'false', :parent => act

    acts =  {:tag => 'timeentryactivities', :children => {:count => 3}, :parent=>p3}
    act = {:tag => 'timeentryactivity', :attributes => {:id => 10}, :parent => acts}
    assert_tag :tag => 'name', :content => 'Development', :parent => act
    assert_tag :tag => 'position', :content => '2', :parent => act
    assert_tag :tag => 'isdefault', :content => 'true', :parent => act

  end

  def test_all_authenticated
    @request.session[:user_id] = 2

    get :all
    assert_response :success
    assert_template 'all.xml.builder'

    xmldoc = XML::Document.string @response.body
    schema = read_schema 'projects'
    valid = xmldoc.validate_schema schema
    assert valid , 'Ergenis passt nicht zum Schema ' + 'projects'

    prjs =  {:tag => 'projects', :children => {:count => 4}, :attributes => {:api => cr}}
    assert_tag prjs

    assert_tag :tag => 'project', :attributes => {:id => 1, :newissueallowed => "true", :moveissueallowed => "true"}, :parent => prjs
    assert_tag :tag => 'project', :attributes => {:id => 2}, :parent => prjs
    assert_tag :tag => 'project', :attributes => {:id => 3}, :parent => prjs
    assert_tag :tag => 'project', :attributes => {:id => 5}, :parent => prjs

  end

end

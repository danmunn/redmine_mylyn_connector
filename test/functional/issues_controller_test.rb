require File.dirname(__FILE__) + '/../test_helper'

class MylynConnector::IssuesControllerTest < MylynConnector::ControllerTest

  fixtures :users, :roles, :members, :issue_categories, :custom_fields, :trackers, :versions, :queries, :projects, :projects_trackers, :custom_fields_trackers, :issues, :journals, :attachments, :custom_fields, :custom_values, :watchers, :time_entries

  def setup
    super
    @controller = MylynConnector::IssuesController.new
  end

  def test_show_unauthenticated
    get :show, :id => 1
    assert_response :success
    assert_template 'show.xml.builder'

    xmldoc = XML::Document.string @response.body
    schema = read_schema 'issue'
    valid = xmldoc.validate_schema schema
    assert valid , 'Ergenis passt nicht zum Schema ' + 'issue'

    i = {:tag => 'issue', :attributes => {:id => 1, :editallowed => 'false', :api => cr}}
    assert_tag i

    assert_tag :tag => 'subject', :content => 'Can\'t print recipes', :parent => i
    assert_tag :tag => 'description',:content => 'Unable to print recipes', :parent => i
    assert_tag :tag => 'createdon', :content => 3.days.ago.to_date.xmlschema, :parent => i
    assert_tag :tag => 'updatedon', :content => 1.days.ago.to_date.xmlschema, :parent => i

    assert_tag :tag => 'trackerid', :content => '1', :parent => i
    assert_tag :tag => 'projectid', :content => '1', :parent => i
    assert_tag :tag => 'statusid', :content => '1', :parent => i
    assert_tag :tag => 'priorityid', :content => '4', :parent => i

    assert_tag :tag => 'watched', :content => 'false', :parent => i
    assert_tag :tag => 'watchers', :attributes => {:viewallowed=>'false', :addallowed=>'false', :deleteallowed=>'false'}, :content => '', :parent => i

    assert_tag :tag=> 'startdate', :content => 1.day.ago.to_date.to_s, :parent => i
    assert_tag :tag=> 'duedate', :content => 10.day.from_now.to_date.to_s, :parent => i
    assert_tag :tag => 'doneratio', :content => '0', :parent => i
    assert_no_tag :tag=> 'estimatedhours', :parent => i

    assert_tag :tag => 'authorid', :content => '2', :parent => i
    assert_tag :tag => 'categoryid', :content => '1', :parent => i
    assert_no_tag :tag => 'assignedtoid', :parent => i
    assert_no_tag :tag => 'fixedversionid', :parent => i
    assert_no_tag :tag => 'parentid', :parent => i

    assert_tag :tag => 'availablestatus', :content => '1', :parent => i

    cfs = {:tag => 'customvalues', :children => {:count => 3}, :parent => i}
    assert_tag :tag => 'customvalue', :attributes => {:customfieldid => 2}, :content => '125', :parent => cfs
    assert_tag :tag => 'customvalue', :attributes => {:customfieldid => 6}, :content => '2.1', :parent => cfs
    assert_tag :tag => 'customvalue', :attributes => {:customfieldid => 8}, :content => '2009-12-01', :parent => cfs

    jrns = {:tag => 'journals', :children => {:count => 2},:parent => i}
    jrn1 = {:tag => 'journal', :attributes => {:id => 1, :editallowed => 'false'}, :parent => jrns}
    assert_tag :tag => 'userid', :content => '1', :parent => jrn1
    assert_tag :tag => 'notes', :content => 'Journal notes', :parent => jrn1
    assert_tag :tag => 'createdon', :content => 2.days.ago.to_date.xmlschema, :parent => jrn1
    jrn2 = {:tag => 'journal', :attributes => {:id => 2, :editallowed => 'false'}, :parent => jrns}
    assert_tag :tag => 'userid', :content => '2', :parent => jrn2
    assert_tag :tag => 'notes', :content => 'Some notes with Redmine links: #2, r2.', :parent => jrn2
    assert_tag :tag => 'createdon', :content => 1.days.ago.to_date.xmlschema, :parent => jrn2

    assert_tag :tag => 'attachments', :children => {:count => 0}, :parent => i

    #TODO issuerelations

    tes = {:tag => 'timeentries', :children => {:count => 3}, :attributes => {:viewallowed => 'true', :newallowed => 'false'}, :parent => i}
    assert_tag :tag => 'sum', :content => '154.25', :parent => tes
    te1 = {:tag => 'timeentry', :attributes => {:id => 1, :editallowed => 'false'}, :parent => tes }
    assert_tag :tag => 'hours', :content => '4.25', :parent => te1
    assert_tag :tag => 'activityid', :content => '9', :parent => te1
    assert_tag :tag => 'userid', :content => '2', :parent => te1
    assert_tag :tag => 'spenton', :content => '2007-03-23', :parent => te1
    assert_tag :tag => 'comments', :content => 'My hours', :parent => te1
    assert_tag :tag => 'customvalues', :children => {:count => 0}, :parent => te1
    te2 = {:tag => 'timeentry', :attributes => {:id => 2, :editallowed => 'false'}, :parent => tes }
    assert_tag :tag => 'hours', :content => '150.0', :parent => te2
    assert_tag :tag => 'activityid', :content => '9', :parent => te2
    assert_tag :tag => 'userid', :content => '1', :parent => te2
    assert_tag :tag => 'spenton', :content => '2007-03-12', :parent => te2
    assert_tag :tag => 'comments', :content => '', :parent => te2
    assert_tag :tag => 'customvalue', :attributes => {:customfieldid => 10}, :content => '2009-12-01', :parent => {:tag => 'customvalues', :children => {:count => 1}, :parent => te2}

  end

  def test_authenticated_attachments
    @request.session[:user_id] = 3

    get :show, :id => 3
    assert_response :success
    assert_template 'show.xml.builder'

    xmldoc = XML::Document.string @response.body
    schema = read_schema 'issue'
    valid = xmldoc.validate_schema schema
    assert valid , 'Ergenis passt nicht zum Schema ' + 'issue'

    i = {:tag => 'issue', :attributes => {:id => '3', :editallowed => 'true', :api => cr}}
    assert_tag i

    assert_tag :tag => 'assignedtoid', :content => '3', :parent => i

    assert_tag :tag => 'watchers', :attributes => {:viewallowed=>'true', :addallowed=>'false', :deleteallowed=>'false'}, :content => '2', :parent => i

    atts = {:tag => 'attachments', :children => {:count => (isMin1dot2? ? 5 : 4)},:parent => i}
    att = {:tag => 'attachment', :attributes => {:id => 1}, :parent => atts}
    assert_tag :tag => 'authorid', :content => '2', :parent => att
    assert_tag :tag => 'contenttype', :content => 'text/plain', :parent => att
    assert_tag :tag => 'filename', :content => 'error281.txt', :parent => att
    assert_tag :tag => 'filesize', :content => '28', :parent => att
    assert_tag :tag => 'digest', :content => 'b91e08d0cf966d5c6ff411bd8c4cc3a2', :parent => att
  end

  def test_authenticated_subtasks
    @request.session[:user_id] = 3

    get :show, :id => 999
    assert_response :success
    assert_template 'show.xml.builder'

    xmldoc = XML::Document.string @response.body
    schema = read_schema 'issue'
    valid = xmldoc.validate_schema schema
    assert valid , 'Ergenis passt nicht zum Schema ' + 'issue'

    i = {:tag => 'issue', :attributes => {:id => '999', :editallowed => 'true', :api => cr}}
    assert_tag i

    assert_tag :tag => 'subtasks', :content => '1000 1001'
  end
  
#  def test_show_assigned
#    get :show, :id => 2
#    assert_response :success
#    assert_template 'show.rxml'
#
#    xmldoc = XML::Document.string @response.body
#    schema = read_schema 'issue'
#    valid = xmldoc.validate_schema schema
#    assert valid , 'Ergenis passt nicht zum Schema ' + 'issue'
#
#    assert_tag :tag => 'fixedversionid', :content => '2'
#    assert_tag :tag => 'assignedtoid', :content => '3'
#    #TODO test mit anmeldung als user #1, watched => true
#    assert_tag :tag => 'watched', :content => false
#    #redmine 0.8: 3
#    #redmine 0.9: 1 & 3
#    assert_tag :tag => 'watchers', :content => /(1 )?3/
#end

  def test_updated_since
    get :updated_since, :issues => '1, 6 ,  8 , 17,20', :unixtime => 11.days.ago.to_i

    assert_response :success
    assert_template 'updated_since.xml.builder'

    xmldoc = XML::Document.string @response.body
    schema = read_schema 'updatedIssues'
    valid = xmldoc.validate_schema schema
    assert valid , 'Ergenis passt nicht zum Schema ' + 'updatedIssues'

    assert_tag :tag => 'updatedissues', :content => '1 8', :attributes => {:api => cr}
  end

  def test_list
    get :list, :issues => '1, 6 ,  8 , 17,20'

    assert_response :success
    assert_template 'list.xml.builder'

    xmldoc = XML::Document.string @response.body
    schema = read_schema 'issues'
    valid = xmldoc.validate_schema schema
    assert valid , 'Ergenis passt nicht zum Schema ' + 'issues'

    lst = {:tag => 'issues', :children => {:count => 2}, :attributes => {:api => cr}}
    assert_tag lst
    assert_tag :tag => 'issue', :attributes => {:id => 1, :editallowed => 'false'}, :parent => lst
    assert_tag :tag => 'issue', :attributes => {:id => 8, :editallowed => 'false'}, :parent => lst

  end

  def test_show_404
    get :show, :id => 99
    assert_response 404
  end

  def test_query_by_id
    get :index, :project_id => 1, :query_id => 1

    assert_response :success
    assert_template 'index.xml.builder'

    #TODO create a schema
#    xmldoc = XML::Document.string @response.body
#    schema = read_schema 'issues'
#    valid = xmldoc.validate_schema schema
#    assert valid , 'Ergenis passt nicht zum Schema ' + 'issues'

    assert_tag :tag => 'issues', :children => {:count => 1}
    assert_tag :tag => 'issue', :attributes => {:id => 3}
  end

  def test_grouped_query_by_id
    get :index, :query_id => 6

    assert_response :success
    assert_template 'index.xml.builder'

    #TODO create a schema
#    xmldoc = XML::Document.string @response.body
#    schema = read_schema 'issues'
#    valid = xmldoc.validate_schema schema
#    assert valid , 'Ergenis passt nicht zum Schema ' + 'issues'

    assert_tag :tag => 'issues', :children => {:count => 9}
    assert_tag :tag => 'issue', :attributes => {:id => 1}
    assert_tag :tag => 'issue', :attributes => {:id => 2}
    assert_tag :tag => 'issue', :attributes => {:id => 3}
    assert_tag :tag => 'issue', :attributes => {:id => 5}
    assert_tag :tag => 'issue', :attributes => {:id => 7}
    assert_tag :tag => 'issue', :attributes => {:id => 13}
  end

#  def test_query_by_string
#    post :query, :project_id => 1, :query_string => 'project_id=1&set_filter=1&fields[]=tracker_id&operators[tracker_id]=%3D&values[tracker_id][]=1&fields[]=category_id&operators[category_id]=!*&values[category_id][]=1'
#
#    assert_response :success
#    assert_template 'index.rxml'
#
#    xmldoc = XML::Document.string @response.body
#    schema = read_schema 'issues'
#    valid = xmldoc.validate_schema schema
#    assert valid , 'Ergenis passt nicht zum Schema ' + 'issues'
#
#    assert_tag :tag => 'issues', :children => {:count => 2}
#    assert_tag :tag => 'issue', :attributes => {:id => 3}
#    assert_tag :tag => 'issue', :attributes => {:id => 7}
#  end
#
#  def test_cross_query_by_string
#    post :query, :query_string => 'set_filter=1&fields[]=tracker_id&operators[tracker_id]=%3D&values[tracker_id][]=1&fields[]=priority_id&operators[priority_id]=%3D&values[priority_id][]=4'
#
#    assert_response :success
#    assert_template 'index.rxml'
#
#    xmldoc = XML::Document.string @response.body
#    schema = read_schema 'issues'
#    valid = xmldoc.validate_schema schema
#    assert valid , 'Ergenis passt nicht zum Schema ' + 'issues'
#
#    #redmine 0.8:
#    #redmine 0.9: 1,3,5,13
#    assert_tag :tag => 'issues', :children => {:count => 3..4}
#    assert_tag :tag => 'issue', :attributes => {:id => 1}
#    assert_tag :tag => 'issue', :attributes => {:id => 3}
#    assert_tag :tag => 'issue', :attributes => {:id => 5}
#    if is09?
#      assert_tag :tag => 'issue', :attributes => {:id => 13}
#    end
#  end
#
#  def test_cross_query_by_string_authenticated
#    @request.session[:user_id] = 2
#    post :query, :query_string => 'set_filter=1&fields[]=tracker_id&operators[tracker_id]=%3D&values[tracker_id][]=1&fields[]=priority_id&operators[priority_id]=%3D&values[priority_id][]=4'
#
#    assert_response :success
#    assert_template 'index.rxml'
#
#    xmldoc = XML::Document.string @response.body
#    schema = read_schema 'issues'
#    valid = xmldoc.validate_schema schema
#    assert valid , 'Ergenis passt nicht zum Schema ' + 'issues'
#
#    assert_tag :tag => 'issue', :attributes => {:id => 1}
#    assert_tag :tag => 'issue', :attributes => {:id => 3}
#    assert_tag :tag => 'issue', :attributes => {:id => 5}
#    assert_tag :tag => 'issue', :attributes => {:id => 4}
#    assert_tag :tag => 'issue', :attributes => {:id => 6}
#  end

end

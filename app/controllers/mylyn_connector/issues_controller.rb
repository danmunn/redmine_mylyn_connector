require File.dirname(__FILE__) + '/../../../lib/mylyn_connector'

class MylynConnector::IssuesController < MylynConnector::ApplicationController
  unloadable
  include MylynConnector::Rescue::ClassMethods

  accept_api_auth :show, :index, :list, :updated_since

  skip_before_filter :verify_authenticity_token

  before_filter :find_optional_project, :only => [:index]
  before_filter :find_issue, :only => [:show]
  before_filter :find_project, :only => [:show]
  before_filter :authorize

  helper MylynConnector::MylynHelper
  helper :queries
  include QueriesHelper
  helper :sort
  include SortHelper

  
  def show
    respond_to do |format|
      format.xml {render :layout => false}
    end
  end

  #TODO not tested
  def index
    retrieve_query

    if @query.valid?
      @issues = @query.issues(:include=>[:assigned_to, :tracker, :priority, :category, :fixed_version])

      respond_to do |format|
        format.xml {render :layout => false}
      end

    else
      respond_to do |format|
        format.xml { head 422 }
      end
    end

  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def updated_since
    time = Time.at(params[:unixtime].to_i)

    issues = params[:issues].split(',')
    issues.collect! { |x| x.to_i }
    issues.uniq!
    issues.compact!

    cond = ActiveRecord::Base.connection.quoted_date(time)

    @issues = Issue.find(
      :all,
      :joins => ["join #{Project.table_name} on project_id=#{Project.table_name}.id"],
      :conditions => ["#{Issue.table_name}.id in (?) and #{Issue.table_name}.updated_on >= ? and " << Project.visible_condition(User.current), issues, cond]
    )
    respond_to do |format|
      format.xml {render :layout => false}
    end
  end

  def list
    issues = params[:issues].split(',')
    issues.collect! { |x| x.to_i }
    issues.uniq!
    issues.compact!

    @issues = Issue.find(
      :all,
      :joins => ["join #{Project.table_name} on project_id=#{Project.table_name}.id"],
      :conditions => ["#{Issue.table_name}.id in (?) and " << Project.visible_condition(User.current), issues]
    )
    respond_to do |format|
      format.xml {render :layout => false}
    end
  end

  private

  def authorize
    if @project
      super :issues, :show;
    else
      super :issues, :show, true
    end
  end

  def find_issue
    @issue = Issue.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_project
    if @issue
      @project = @issue.project
    elsif !params[:project_id].blank?
      begin
        @project = Project.find(params[:project_id])
      rescue ActiveRecord::RecordNotFound
        render_404
      end
    end
  end

  def find_optional_project
    @project = Project.find(params[:project_id]) unless params[:project_id].blank?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end

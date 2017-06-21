
module MylynConnector::IssuesHelper
  include MylynConnector::Version::ClassMethods

  def edit_allowed? issue
    res = User.current.allowed_to?(:edit_issues, issue.project)
    return res !=nil && res !=false
  end

  def available_status issue
    status = issue.new_statuses_allowed_to(User.current)
    if !status.include?(issue.status)
      status.unshift(issue.status);
    end
    status.compact!
    return status
  end

  def journals issue
    issue.journals.find(:all, :conditions => ["notes IS NOT NULL AND notes != ''"])
  end

  def list_status availableStatus
    availableStatus.collect! { |i| i.id.to_s + " "}
    availableStatus.to_s.strip
  end

  def time_entries_view_allowed?(issue)
    return (issue.project.module_enabled?(:time_tracking) && User.current.allowed_to?(:view_time_entries, issue.project)) ? true : false
  end

  def time_entries_new_allowed?(issue)
    return (issue.project.module_enabled?(:time_tracking) && User.current.allowed_to?(:log_time, issue.project)) ? true : false
  end

  def watchers_view_allowed?(issue)
    return User.current.allowed_to?(:view_issue_watchers, issue.project) ? true : false
  end

  def watchers_add_allowed?(issue)
    return User.current.allowed_to?(:add_issue_watchers, issue.project) ? true : false
  end

  def watchers_delete_allowed?(issue)
    return User.current.allowed_to?(:delete_issue_watchers, issue.project) ? true : false
  end

  def watched?(issue)
    return false unless User.current.logged?
    return issue.watched_by?(User.current)
  end

  def subtasks(issue)
    begin
        Issue.find(:all, :joins => :project, :conditions => ["#{Issue.table_name}.parent_id=? AND (" + Issue.visible_condition(User.current) + ")", issue])
      rescue
        issue.children.to_a.reject{|i|
          !User.current.allowed_to?({:controller => :issues, :action => :show}, i.project || @projects)
        }
      end unless (issue.leaf?)
  end

end

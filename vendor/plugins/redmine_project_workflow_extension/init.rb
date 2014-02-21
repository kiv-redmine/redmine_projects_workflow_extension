require 'redmine'
require 'redmine_project_workflow_extension'

Redmine::Plugin.register :redmine_project_workflow_extension do
  name 'Redmine Project Workflow Extension plugin'
  author 'Jan Strnadek <jan.strnadek@gmail.com>'
  description 'Extension for redmine project workflow'
  version '0.0.1'
  url 'https://github.com/Strnadj/redmine13_project_workflow_extension'
  author_url 'http://strnadj.github.io/'
end

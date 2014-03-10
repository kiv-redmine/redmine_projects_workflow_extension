class MilestonesController < ApplicationController
  before_filter :find_project, :only => [:index, :new, :create, :show]
  before_filter :find_milestone, :only => [ :show, :edit, :update, :destroy ]
  #TODO:: Remove after fix permissions before_filter :authorize

  def index
    respond_to do |format|
      format.html {
        @milestones = @project.milestones.all
      }
      format.api {
        @milestones = @project.milestones.all
      }
    end
  end

  def show
    respond_to do |format|
      format.html {
        @milestone
      }
      format.api {
        @milestone
      }
    end
  end

  def new
    @milestone = @project.milestones.build
    if params[:milestone]
      attributes = params[:milestone].dup
      @milestone.safe_attributes = attributes
    end
  end

  def create
    @milestone = @project.milestones.build
    if params[:milestone]
      attributes = params[:milestone].dup
      @milestone.safe_attributes = attributes
    end

    if request.post?
      if @milestone.save
        respond_to do |format|
          format.html do
            flash[:notice] = l(:notice_successful_create)
            redirect_back_or_default (:controller => 'projects', :action => 'settings', :tab => 'milestones', :id => @project.identifier)
          end
          format.api do
            render :action => 'show', :status => :created, :location => milestone_url(@milestone)
          end
        end
      else
        respond_to do |format|
          format.html { render :action => 'new' }
          format.api  { render_validation_errors(@milestone) }
        end
      end
    end
  end

  def edit
  end

  def update
    if request.put? && params[:milestone]
      attributes = params[:milestone].dup
      @milestone.safe_attributes = attributes
      if @milestone.save
        respond_to do |format|
          format.html {
            flash[:notice] = l(:notice_successful_update)
            redirect_back_or_default :controller => 'projects', :action => 'settings', :tab => 'milestones', :id => @project
          }
          format.api  { head :ok }
        end
      else
        respond_to do |format|
          format.html { render :action => 'edit' }
          format.api  { render_validation_errors(@milestone) }
        end
      end
    end
  end

  verify :method => :delete, :only => :destroy, :render => {:nothing => true, :status => :method_not_allowed }
  def destroy
    @milestone.destroy
    respond_to do |format|
      format.html { redirect_to(:controller => 'projects', :action => 'settings', :tab => 'milestones', :id => @milestone.project.identifier) }
      format.api  { head :ok }
    end
  end

  private

  def find_milestone
    @milestone = Milestone.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end

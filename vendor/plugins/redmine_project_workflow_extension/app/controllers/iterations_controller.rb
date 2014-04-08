class IterationsController < ApplicationController
  # Find project & find iteration for edit actions
  before_filter :find_project, :only => [:index, :new, :create, :show]
  before_filter :find_iteration, :only => [ :show, :edit, :update, :destroy ]
  before_filter :authorize

  def index
    respond_to do |format|
      format.html {
        @iterations = @project.iterations.all
      }
      format.api {
        @iterations = @project.iterations.all
      }
    end
  end

  def show
    respond_to do |format|
      format.html {
        @iteration
      }
      format.api {
        @iteration
      }
    end
  end

  def new
    @iteration = @project.iterations.build
    if params[:iteration]
      attributes = params[:iteration].dup
      @iteration.safe_attributes = attributes
    end
  end

  def create
    @iteration = @project.iterations.build
    if params[:iteration]
      attributes = params[:iteration].dup
      @iteration.safe_attributes = attributes
    end

    if request.post?
      if @iteration.save
        respond_to do |format|
          format.html do
            flash[:notice] = l(:notice_successful_create)
            redirect_back_or_default (:controller => 'projects', :action => 'settings', :tab => 'iterations', :id => @project.identifier)
          end
          format.api do
            render :action => 'show', :status => :created, :location => iteration_url(@iteration)
          end
        end
      else
        respond_to do |format|
          format.html { render :action => 'new' }
          format.api  { render_validation_errors(@iteration) }
        end
      end
    end
  end

  def edit
  end

  def update
    if request.put? && params[:iteration]
      attributes = params[:iteration].dup
      @iteration.safe_attributes = attributes
      if @iteration.save
        respond_to do |format|
          format.html {
            flash[:notice] = l(:notice_successful_update)
            redirect_back_or_default :controller => 'projects', :action => 'settings', :tab => 'iterations', :id => @project
          }
          format.api  { head :ok }
        end
      else
        respond_to do |format|
          format.html { render :action => 'edit' }
          format.api  { render_validation_errors(@iteration) }
        end
      end
    end
  end

  verify :method => :delete, :only => :destroy, :render => {:nothing => true, :status => :method_not_allowed }
  def destroy
    @iteration.destroy
    respond_to do |format|
      format.html { redirect_to(:controller => 'projects', :action => 'settings', :tab => 'iterations', :id => @iteration.project.identifier) }
      format.api  { head :ok }
    end
  end

  private

  def find_iteration
    @iteration = Iteration.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end

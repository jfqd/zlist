class SubscribersController < ApplicationController

  skip_before_filter :login_required, :only => %w(new create)
  before_filter :admin_required, :only => %w(index destroy disable)
  before_filter :find_subscriber, :only => %w(show edit update destroy disable)

  def index
    @subscribers = Subscriber.active.paginate(page: params[:page])
  end

  def search
    @subscribers = Subscriber.active.search(params[:search][:q]).paginate(page: params[:page])
    render 'index'
  end

  def show
  end

  def new
    @subscriber = Subscriber.new
    render :layout => 'login' if !logged_in?
  end

  def edit
  end

  def create
    admin = (subscriber_params[:admin] == '1')
    subscriber_params.delete :admin
    @subscriber = Subscriber.new(subscriber_params)
    if subscriber_params[:password].present? || subscriber_params[:password_confirmation].present?
      @subscriber.saving_password = true
    end
    @subscriber.admin = admin
    if @subscriber.save
      if logged_in? && admin?
        flash[:notice] = 'Subscriber was successfully created.'
        redirect_to subscribers_path
      else
        flash[:notice] = 'Thanks for signing up!  You are now logged in.'
        session[:subscriber_id] = @subscriber.id if @subscriber.password_hash.present?
        redirect_to_target_or_default('/')
      end
    else
      if logged_in?
        render :action => "new"
      else
        render :action => "new", :layout => "login"
      end
    end
  end

  def update
    @subscriber.assign_attributes(subscriber_params)
    if subscriber_params[:password].present? || subscriber_params[:password_confirmation].present?
      @subscriber.saving_password = true
    end
    if @subscriber.save
      flash[:notice] = 'Subscriber was successfully updated.'
      redirect_to(subscribers_path)
    else
      render :action => "edit"
    end
  end

  def destroy
    if @subscriber == current_user
      flash[:alert] = "You can't delete yourself.  If you really want to go, have another admin delete you."
    else
      @subscriber.destroy
    end
    redirect_to(subscribers_url)
  end

  def disable
    @subscriber.disable
    redirect_to(subscribers_url)
  end

  private

  def find_subscriber
    if admin?
      @subscriber = Subscriber.find(params[:id])
    else
      @subscriber = current_user
    end
  end
  
  def subscriber_params
    params.require(:subscriber).permit(:name, :email, :password, :password_confirmation)
  end
end

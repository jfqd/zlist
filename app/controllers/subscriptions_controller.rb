class SubscriptionsController < ApplicationController
  
  before_filter :find_subscription, :only => %w(show edit update destroy)
  before_filter :admin_required
  
  def index
    @subscriptions = Subscription.all
  end

  def show
  end

  def new
    @subscription = Subscription.new
  end

  def edit
  end

  def create
    @subscription = Subscription.create(subscription_params)
    @list = @subscription.list
    redirect_to :back
  end

  def update
    if @subscription.update_attributes(subscription_params)
      flash[:notice] = 'Subscription was successfully updated.'
      redirect_to @subscription
    else
      render "edit"
    end
  end

  def destroy
    @list = @subscription.list
    @subscription.destroy
    redirect_to :back
  end
  
  private
  
  def find_subscription
    @subscription = Subscription.find(params[:id])
  end
  
  def subscription_params
    params.require(:subscription).permit(:list_id, :subscriber_id)
  end
end

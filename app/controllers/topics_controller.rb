class TopicsController < ApplicationController
  before_action :find_list
  before_action :find_topic, :only => %w(show edit update destroy)

  def index
    @topics = @list.topics.includes(:messages).order('created_at DESC').paginate(page: params[:page], per_page: 20)
  end

  def show
    @messages = @topic.messages.order('created_at DESC').paginate(page: params[:page], per_page: 10)
  end

  def new
    @topics = @list.topics.new
  end

  def edit
  end

  def create
    @topic = @list.topics.build(params[:topic])
    if @topic.save
      flash[:notice] = 'Topic was successfully created.'
      redirect_to(@topic)
    else
      flash.now[:alert] = 'There was a problem creating the topic.'
      render :action => "new"
    end
  end

  def update
    if @topic.update_attributes(params[:topic])
      flash[:notice] = 'Topic was successfully updated.'
      redirect_to(@topic)
    else
      flash.now[:alert] = 'There was a problem updating the topic.'
      render :action => "edit" 
    end
  end

  def destroy
    @topic.destroy
    flash[:notice] = "The topic was deleted."
    redirect_to(topics_url)
  end

  private
  
  def find_list
    @list = List.find(params[:list_id])
  end
  
  def find_topic
    @topic = @list.topics.find(params[:id])
  end

end

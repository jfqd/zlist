class ListsController < ApplicationController
  
  before_filter :find_list, :only => %w(show edit send_test update destroy)

  def index
    @lists = List.all(:include => :subscribers)
  end

  def show
  end

  def new
    @list = List.new
  end

  def edit
  end

  def create
    @list = List.new(params[:list])
    if @list.save
      flash[:notice] = 'List was successfully created.'
      redirect_to(@list)
    else
      flash.now[:warning] = 'There was a problem creating the list.'
      render :action => "new"
    end
  end

  def update
    if @list.update_attributes(params[:list])
      flash[:notice] = 'List was successfully updated.'
      redirect_to(@list)
    else
      flash.now[:warning] = 'There was a problem updating the list.'
      render :action => "edit" 
    end
  end

  def destroy
    @list.destroy
    flash[:notice] = "The list was deleted."
    redirect_to(lists_url)
  end

  def send_test
    if Mailman.deliver_list_test_dispatch(@list)
      flash[:notice] = 'Test message sent'
    else
      flash[:notice] = 'Test message failed'
    end
    redirect_to(@list)
  end
  
  protected
  
  def find_list
    @list = List.find(params[:id])
  end
end

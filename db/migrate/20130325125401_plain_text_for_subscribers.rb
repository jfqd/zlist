class PlainTextForSubscribers < ActiveRecord::Migration
  def up
    add_column :subscribers, :plain_text, :boolean, :default => false
  end

  def down
    remove_column :subscribers, :plain_text
  end
end

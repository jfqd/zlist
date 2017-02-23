class RevertToEmailField < ActiveRecord::Migration
  def self.up
    rename_column :lists, :short_name, :mailbox
  end

  def self.down
    rename_column :lists, :email, :mailbox
  end
end

# Redmine - project management software
# Copyright (C) 2006-2013  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

namespace :zlist do
  namespace :email do

    desc <<-END_DESC
Read emails from an IMAP server.

Available IMAP options:
  host=HOST                IMAP server host (default: 127.0.0.1)
  port=PORT                IMAP server port (default: 143)
  ssl=SSL                  Use SSL? (default: false)
  username=USERNAME        IMAP account
  password=PASSWORD        IMAP password
  folder=FOLDER            IMAP folder to read (default: INBOX)
  
Processed emails control options:
  move_on_success=MAILBOX  move emails that were successfully received
                           to MAILBOX
  move_on_failure=MAILBOX  move emails that were ignored to MAILBOX

Examples:

  rake zlist:email:receive_imap RAILS_ENV="production"

END_DESC

    task :receive_imap => :environment do
      imap_options = {
        :host => ENV['host'],
        :port => ENV['port'],
        :ssl  => ENV['ssl'],
        :username => ENV['username'],
        :password => ENV['password'],
        :folder   => ENV['folder'],
        :move_on_success => ENV['move_on_success'],
        :move_on_failure => ENV['move_on_failure']
      }
      Zlist::Imap.check(imap_options)
    end
    
  end
end

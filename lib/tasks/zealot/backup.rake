# frozen_string_literal: true

# Copyright (c) 2011-present GitLab B.V.

# Portions of this software are licensed as follows:

# * All content residing under the "doc/" directory of this repository is licensed under
#   "Creative Commons: CC BY-SA 4.0 license".
# * All content that resides under the "ee/" directory of this repository, if that directory exists,
#   is licensed under the license defined in "ee/LICENSE".
# * All client-side JavaScript (when served directly or after being compiled, arranged, augmented, or combined),
#   is licensed under the "MIT Expat" license.
# * All third party components incorporated into the GitLab Software are licensed
#   under the original license provided by the owner of the applicable component.
# * Content outside of the above mentioned directories or restrictions above is available
#   under the "MIT Expat" license as defined below.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# require_relative '../../zealot/backup/helper'

# extend Zealot::Backup::Helper

# namespace :zealot do
#   namespace :backup do
#     desc 'Zealot | Backup | Create a backup of the Zealot system'
#     task create: :environment do
#       Rake::Task['zealot:backup:db:create'].invoke
#       Rake::Task['zealot:backup:uploads:create'].invoke

#       backup = Zealot::Backup::Manager.new
#       backup.write_info
#       backup.pack
#       backup.cleanup
#       backup.remove_old
#     end

#     desc 'Zealot | Backup | Restore a previously created backup'
#     task restore: :environment do
#       backup = Zealot::Backup::Manager.new
#       cleanup_required = backup.unpack
#       backup.verify_backup_version

#       Rake::Task['zealot:backup:db:restore'].invoke
#       Rake::Task['zealot:backup:uploads:restore'].invoke

#       backup.cleanup if cleanup_required

#       puts "Restore task is done."
#     end

#     namespace :uploads do
#       task create: :environment do
#         Zealot::Backup::Uploads.dump
#       end

#       task restore: :environment do
#         Zealot::Backup::Uploads.restore
#       end
#     end

#     namespace :db do
#       task create: :environment do
#         Zealot::Backup::Database.dump
#       end

#       task restore: :environment do
#         Zealot::Backup::Database.restore
#       end
#     end
#   end
# end

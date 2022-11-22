# frozen_string_literal: true

# Copyright (c) 2011-present GitLab B.V.

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

module Zealot::Backup
  module Helper

    def backup_root_path
      Setting.backup[:path]
    end

    def gzip_cmd
      @gzip_cmd ||= if ENV['ZEALOT_BACKUP_GZIP_RSYNCABLE'] == 'yes'
                      "gzip --rsyncable -c -1"
                    else
                      "gzip -c -1"
                    end
    end

    def tar
      @tar ||= if system(*%w[gtar --version], out: '/dev/null')
                 # It looks like we can get GNU tar by running 'gtar'
                 'gtar'
               else
                 'tar'
               end
    end

    def access_denied_error(path)
      message = <<~EOF

      ### NOTICE ###
      As part of restore, the task tried to move existing content from #{path}.
      However, it seems that directory contains files/folders that are not owned.
      To proceed, please move the files or folders inside #{path} to a secure
      location so that #{path} is empty and run restore task again.

      EOF
      raise message
    end

    def resource_busy_error(path)
      message = <<~EOF

      ### NOTICE ###
      As part of restore, the task tried to rename `#{path}` before restoring.
      This could not be completed, perhaps `#{path}` is a mountpoint?

      To complete the restore, please move the contents of `#{path}` to a
      different location and run the restore task again.

      EOF
      raise message
    end
  end
end
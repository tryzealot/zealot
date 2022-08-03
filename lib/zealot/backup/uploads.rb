# frozen_string_literal: true

# Copyright (c) 2011-present GitLab B.V.

# Portions of this software are licensed as follows:

# * All content residing under the "doc/" directory of this repository is licensed under "Creative Commons: CC BY-SA 4.0 license".
# * All content that resides under the "ee/" directory of this repository, if that directory exists, is licensed under the license defined in "ee/LICENSE".
# * All client-side JavaScript (when served directly or after being compiled, arranged, augmented, or combined), is licensed under the "MIT Expat" license.
# * All third party components incorporated into the GitLab Software are licensed under the original license provided by the owner of the applicable component.
# * Content outside of the above mentioned directories or restrictions above is available under the "MIT Expat" license as defined below.

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

require 'open3'

module Zealot::Backup
  class Uploads
    include Zealot::Backup::Helper

    class Error < StandardError; end

    def self.dump
      new.dump
    end

    def self.restore
      new.restore
    end

    def dump
      FileUtils.mkdir_p(backup_path)
      FileUtils.rm_f(backup_tarball)

      _logger.debug "Dumping uploads data ... "

      run_pipeline!([%W(#{tar} --exclude=lost+found -C #{uploads_path} -cf - .), gzip_cmd], out: [backup_tarball, 'w', 0600])
    end

    def restore
      _logger.debug "Restoring uploads data ... "

      backup_existing_uploads_dir
      FileUtils.mkdir_p(uploads_path)
      run_pipeline!([%w(gzip -cd), %W(#{tar} #{gzip_args} -C #{uploads_path} -xf -)], in: backup_tarball)
    end

    private

    def backup_existing_uploads_dir
      timestamped_files_path = File.join(backup_path, "tmp", "uploads.old.#{Time.now.to_i}")
      if File.exist?(uploads_path)
        # Move all files in the existing repos directory except . and .. to
        # uploads.old.<timestamp> directory
        FileUtils.mkdir_p(timestamped_files_path, mode: 0700)
        files = Dir.glob(File.join(uploads_path, "*"), File::FNM_DOTMATCH) - [File.join(uploads_path, "."), File.join(uploads_path, "..")]

        begin
          FileUtils.mv(files, timestamped_files_path)
        rescue Errno::EACCES
          access_denied_error(uploads_path)
        rescue Errno::EBUSY
          resource_busy_error(uploads_path)
        end
      end
    end

    def run_pipeline!(cmd_list, options = {})
      err_r, err_w = IO.pipe
      options[:err] = err_w

      status = Open3.pipeline(*cmd_list, options)
      err_w.close
      return true if status.compact.all?(&:success?)

      regex = /^g?tar: \.: Cannot mkdir: No such file or directory$/
      error = err_r.read
      raise Backup::Uploads::Error, "Backup failed: #{error}" unless error =~ regex
    end

    def gzip_args
      require 'rbconfig'

      # https://www.gnu.org/software/tar/manual/html_node/Unlink-First.html
      args = ['--unlink-first']

      unless RbConfig::CONFIG['host_os'] =~ /darwin|mac os/
        # https://www.gnu.org/software/tar/manual/html_node/Recursive-Unlink.html
        args << '--recursive-unlink'
      end

      args.join(' ')
    end

    def backup_tarball
      @backup_tarball ||= File.join(backup_path, 'uploads.tar.gz')
    end

    def uploads_path
      @uploads_path ||= Rails.root.join('public', 'uploads')
    end
  end
end
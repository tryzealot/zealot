# frozen_string_literal: true

require 'pathname'

module BackupFile
  extend ActiveSupport::Concern

  class PerformingJob
    attr_reader :job, :status
    def initialize(job, status)
      @job = job
      @status = status
    end
  end

  class BackupFile
    attr_reader :status

    delegate :size, :ctime, :to_path, :basename, to: :@file

    def initialize(file)
      @file = Pathname.new(file)
    end

    def shortname
      @shortname ||= "#{name.split('_')[-3..-1].join('_')}"
    end

    def name
      @name ||= @file.basename.to_s
    end

    def created_at
      @file.ctime
    end

    def sha256
      @sha256 ||= File.read(sha256_file)
    end

    def current_status
      completed? ? 'completed' : 'unknown'
    end

    def completed?
      backup_exist? && sha256_exist?
    end

    def backup_exist?
      File.exist?(@file)
    end

    def sha256_exist?
      File.exist?(sha256_file)
    end

    def matched?
      source = Digest::SHA256.file(@file).hexdigest
      source == sha256
    end

    def sha256_file
      @sha256_file ||= Pathname.new("#{@file.to_path}.sha256")
    end
  end
end

module Api
  module V1
    class AppController < Api::ApplicationController
      before_filter :validate_params
      before_action :set_app, only: [:info, :versions, :changelogs, :latest, :install_url]

      def upload
        @app = App.find_or_initialize_by(identifier: params[:identifier])
        @app.identifier = params[:identifier] if @app.new_record?
        @app.name = params[:name]
        @app.slug = params[:slug] if params[:slug]
        @app.device_type = params[:device_type]
        @app.user = @user

        if @app.invalid?
          return render json: {
            error: '上次错误，请检查原因！',
            reason: @app.errors.messages
          }, status: 400
        end

        @app.save!

        file_md5 = Digest::MD5.hexdigest(params[:file].tempfile.read.to_s)

        status = 200
        @release = @app.releases.find_by(
          identifier: params[:identifier],
          release_version: params[:release_version],
          build_version: params[:build_version],
          last_commit: params[:last_commit],
          md5: file_md5
        )

        unless @release
          status = 201

          web_hooks = WebHook.where(upload_events: 1, app: @app)
          web_hooks.each do |web_hook|
            AppWebHookJob.perform_later 'upload_events', web_hook
          end unless web_hooks.empty?

          extra = params.clone
          extra.delete(:file)
          @release = @app.releases.create(
            identifier: params[:identifier],
            release_version: params[:release_version],
            build_version: params[:build_version],
            store_url: params[:store_url],
            icon: params[:icon_url],
            changelog: params[:changelog],
            channel: params[:channel],
            branch: params[:branch],
            last_commit: params[:last_commit],
            ci_url: params[:ci_url],
            file: params[:file],
            extra: JSON.dump(extra)
          )
        end

        # 新上传的版本分支不存在于缓存中清除缓存
        app_branches_cache_key = "app_#{@app_id}_branches"
        if Rails.cache.exist?(app_branches_cache_key) &&
           @app.branches.select { |m| m.branch == @release.branch }.empty?

          Rails.cache.delete(app_branches_cache_key)

        end

        render json: @release.to_json(include: [:app]), status: status
      end

      def info
        if @app
          render json: @app.to_json(
            include: [:releases],
            except: [:id, :password, :key]
          )
        else
          render json: {
            error: 'App is missing',
            params: params
          }, status: 404
        end
      end

      def versions
        if @app
          # data[:version] = @app.releases.latest.version
          # data[:release_version] = @app.releases.latest.release_version
          # data[:build_version] = @app.releases.latest.build_version
          data['versions'] = @app.releases.order(created_at: :desc).limit(10).to_json

          render json: data
        else

          render json: {
            error: 'App is missing',
            params: params
          }, status: 404
        end
      end

      def changelogs
        if @app
          release = Release.find_by(app: @app,
                                    release_version: params[:release_version],
                                    build_version: params[:build_version])
          if release
            @releases = Release.where(app: @app)
                               .where('version > ? AND build_version > ?', release.version, release.build_version)
                               .order(version: :desc)
          end
        else
          render json: {
            error: 'not found app'
          }, status: 404
        end
      end

      def latest
        return if @app

        render json: {
          error: 'not found app'
        }, status: 404
      end

      def install_url
        @release =
          if params[:release_id]
            Release.find(params[:release_id])
          else
            @app.releases.last
          end

        if @app && @release
          case @app.device_type.downcase
          when 'iphone', 'ipad', 'ios'
            render 'apps/install_url',
                   handlers: [:plist],
                   content_type: 'text/xml'
          when 'android'
            redirect_to api_app_download_path(release_id: @release.id)
          end
        else
          render json: {
            error: 'app not had any release'
          }, status: 404
        end
      end

      def download
        @release = Release.find(params[:release_id])

        headers['Content-Length'] = @release.filesize
        send_file @release.file.path,
                  filename: @release.download_filename
      end

      private

      def set_app
        @app =
          if params.key?(:slug)
            App.find_by(slug: params[:slug])
          else
            App.find_by(identifier: params[:identifier])
          end
      end

      def validate_params
        @user = User.find_by(key: params[:key])
        return if %w(install_url download).include?(params[:action])
        return if params.key?(:key) && @user

        render json: {
          error: '无效用户 Key'
        }, status: 401
      end
    end
  end
end

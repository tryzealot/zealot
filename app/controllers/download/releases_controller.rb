# frozen_string_literal: true

class Download::ReleasesController < ApplicationController
  before_action :set_release

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_entity_response

  def show
    # password protected check
    unless helpers.logged_in_or_without_auth?(@release) 
      return redirect_to channel_release_path(@release.channel, @release, back_url: @release.download_url)
    end

    return render_not_found_entity_response unless File.exist?(@release.file.path.to_s)

    redirect_to filename_download_release_url(@release, @release.download_filename)
  end

  def download
    # password protected check — this is the URL #show redirects to once the
    # channel password is verified, but it is also directly routable, so it
    # has to repeat the check rather than rely on #show having done it.
    unless helpers.logged_in_or_without_auth?(@release)
      return redirect_to channel_release_path(@release.channel, @release, back_url: @release.download_url)
    end

    # 触发 web_hook
    @release.channel.perform_web_hook('download_events', current_user&.id)

    headers['Content-Length'] = @release.file.size
    send_file @release.file.path,
              filename: @release.download_filename,
              disposition: 'attachment'
  end

  private

  def render_not_found_entity_response
    render json: {
      error: t('.not_found')
    }, status: :not_found
  end


  def set_release
    @release = Release.find(params[:id])
  end
end



class DownloadsController < ApplicationController
  skip_before_action :require_user_token
  before_action :allow_cors

  # Allow Cross Orgin requests to serve screenshots
  def allow_cors

    headers["Access-Control-Allow-Origin"] = "*"
    headers["Access-Control-Allow-Methods"] = %w{GET}.join(",")
    headers["Access-Control-Allow-Headers"] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token}.join(",")

    head(:ok) if request.request_method == "OPTIONS"

  end


  api :GET, '/downloads/:token', 'Access download'
  description 'Directly access download file found via download token.'
  param 'User-Token', nil
  param :token, String, 'Download token', required: true
  meta 'Unauthenticated path.  User-Token header is not required'
  see "results#screenshot", "results#screenshot for token generation example"
  def show

    dl = DownloadToken.find_by_token(params[:token])

    render json: {error: "Download not found"},
           status: :not_found and return unless dl

    if dl.expiration < DateTime.now

      if dl.remove
        File.delete(dl.path)
      end

      dl.destroy

      render json: {error: "Screenshot token has expired"},
             status: :unauthorized and return
    end


    file_path = dl.path
    file_name = dl.filename
    file_content_type = dl.content_type
    file_disposition = dl.disposition
    remove_file = dl.remove

    dl.destroy

    send_file file_path, type: file_content_type, disposition: file_disposition, filename: file_name and return

    if remove_file
      File.delete(file_path)
    end

  end
end

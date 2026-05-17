class DownloaderController < ApplicationController
  before_action :authenticate_token!, only: :show

  def index
    render json: { status: "ok", usage: "GET /api/get?url=<encoded_url> with X-Api-Key header" }
  end

  def show
    url = params.require(:url)

    cached = Rails.cache.fetch(["yt-dlp", url], expires_in: 30.minutes) do
      cmd = Terrapin::CommandLine.new(
        "yt-dlp",
        "--no-warnings --no-playlist --no-download --dump-single-json --cookies /etc/yt-dlp/cookies.txt :url",
        expected_outcodes: [0]
      )
      JSON.parse(cmd.run(url: url))
    end

    best = cached["url"] || pick_best_format(cached["formats"])

    render json: {
      title: cached["title"],
      ext: cached["ext"],
      thumbnail: cached["thumbnail"],
      duration: cached["duration"],
      url: best,
      audio_url: pick_audio_only(cached["formats"])
    }
  rescue Terrapin::ExitStatusError => e
    render json: { error: e.message[0..200] }, status: :unprocessable_entity
  rescue Terrapin::CommandNotFoundError
    render json: { error: "yt-dlp not installed" }, status: :service_unavailable
  end

  private

  def pick_best_format(formats)
    formats&.reverse&.find { |f| f["vcodec"] != "none" && f["acodec"] != "none" }&.dig("url")
  end

  def pick_audio_only(formats)
    return nil unless formats

    video = formats.reverse.find { |f| f["vcodec"] != "none" && (f["acodec"].nil? || f["acodec"] == "none") }
    return nil unless video

    formats.reverse.find { |f| f["acodec"] != "none" && (f["vcodec"].nil? || f["vcodec"] == "none") }&.dig("url")
  end

  def authenticate_token!
    head :unauthorized unless request.headers["X-Api-Key"] == ENV["DOWNLOADER_API_KEY"]
  end
end

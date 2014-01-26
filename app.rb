require "sinatra/base"
require "slim"
require "compare_linker"
require "compare_linker/webhook_payload"

class Public < Sinatra::Base
  configure do
    enable :logging
    Slim::Engine.default_options[:pretty] = true
  end

  get "/" do
    slim :index
  end
end

class Protected < Sinatra::Base
  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == ENV["USERNAME"] && password == ENV["PASSWORD"]
  end

  helpers do
    def make_and_post_compare_links(repo_full_name, pr_number)
      compare_linker = CompareLinker.new(repo_full_name, pr_number)
      compare_linker.formatter = CompareLinker::Formatter::Markdown.new
      compare_links = compare_linker.make_compare_links.join("\n")

      if compare_links.nil? || compare_links.empty?
        logger.info "no compare links"
      else
        comment_url = compare_linker.add_comment(repo_full_name, pr_number, compare_links)
        logger.info comment_url
      end
    end

    post "/webhook" do
      payload = CompareLinker::WebhookPayload.new(params["payload"])
      if payload.action == "opened"
        logger.info "action=#{payload.action} repo_full_name=#{payload.repo_full_name} pr_number=#{payload.pr_number}"
        make_and_post_compare_links(payload.repo_full_name, payload.pr_number)
      end
    end

    post "/webhook_backdoor" do
      logger.info "repo_full_name=#{params['repo_full_name']} pr_number=#{params['pr_number']}"
      make_and_post_compare_links(params["repo_full_name"], params["pr_number"])
    end
  end
end

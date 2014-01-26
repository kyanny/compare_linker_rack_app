require "uri"
require "octokit"

def get_config(key)
  if $config
    return $config[key]
  else
    $config = {}
    `heroku config --shell`.each_line do |line|
      k, v = line.split("=")
      $config[k.chomp] = v.chomp
    end
    return $config[key]
  end
end

octokit_access_token = get_config("OCTOKIT_ACCESS_TOKEN")
username = get_config("USERNAME")
password = get_config("PASSWORD")
repo_full_name = ARGV[0]

if octokit_access_token.nil? || username.nil? || password.nil? ||  repo_full_name.nil?
  puts <<USAGE
Usage: heroku config:set OCTOKIT_ACCESS_TOKEN=[your github access token]
                         USERNAME=[basic auth username]
                         PASSWORD=[basic auth password]
       ruby #{$0} [repo_full_name]
USAGE
  exit!
end

webhook_url = URI(`heroku apps:info`.match(/^Web URL:\s+(\S+)/)[1]).tap do |uri|
  uri.scheme = "https"
  uri.user = username
  uri.password = password
  uri.path = "/p/webhook"
end

octokit = Octokit::Client.new(access_token: octokit_access_token)
res = octokit.create_hook(
  repo_full_name,
  "web",
  {
    url: webhook_url.to_s,
  },
  {
    events: ["pull_request"],
    active: true,
  }
)
if res.active
  puts "Webhook added: https://github.com/#{repo_full_name}/settings/hooks"
end

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
owner, repo_name = ARGV[0].to_s.split("/")

if octokit_access_token.nil? || owner.nil?
  puts <<USAGE
Usage: heroku config:set OCTOKIT_ACCESS_TOKEN=[your github access token]
       ruby #{$0} [owner/repo_name]
       ruby #{$0} [owner]
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
octokit.auto_paginate = true
if repo_name.nil?
  repos = begin
            octokit.org_repos(owner)
          rescue
            octokit.repos(owner)
          end
else
  repos = [octokit.repo("#{owner}/#{repo_name}")]
end

repos.each do |repo|
  begin
    hook = octokit.hooks("#{repo.full_name}").detect { |h|
      h.name == "web" && h.events.include?("pull_request") && (h.config.rels && h.config.rels[:self] && h.config.rels[:self].href == webhook_url.to_s)
    }
    if hook.nil?
      puts "Not Installed: #{repo.full_name}"
    else
      if hook.active
        puts "Active: #{repo.full_name}"
      else
        puts "Inactive: #{repo.full_name}"
      end
    end
  rescue => e
    # puts "Error: #{owner}/#{repo_name} - #{e}"
  end
end

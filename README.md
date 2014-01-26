CompareLinker Rack App
======================

Heroku Setup
------------

Prerequisite: Heroku Toolbelt https://toolbelt.heroku.com/

1. Clone this repository
------------------------

```
$ git clone https://github.com/kyanny/compare_linker_rack_app.git
```

2. Create new Heroku app
------------------------

```
$ heroku apps:create
```

3. Deploy to Heroku
-------------------

```
$ git push heroku master
```

4. Add config variables
-----------------------

```
$ heroku config:set OCTOKIT_ACCESS_TOKEN=[your github access token]
$ heroku config:set USERNAME=[basic auth username]
$ heroku config:set PASSWORD=[basic auth password]
```

If you don't have GitHub Access Token, create it.
https://github.com/settings/tokens/new

5. Create Webhook to your repository
------------------------------------

```
$ ruby add_webhook.rb [repo_full_name]
```

`repo_full_name` is `owner/repo_name` format. e.g. `kyanny/compare_linker_demo`

6. Open new Pull Request
------------------------

That's all! When you open new pull request, you'll see new issue comment with compare links like this.
https://github.com/kyanny/compare_linker_demo/pull/13#issuecomment-33319142

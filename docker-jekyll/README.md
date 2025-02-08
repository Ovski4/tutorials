Install jekyll with docker

-> article 1.

Image available at https://hub.docker.com/r/jekyll/jekyll/ but not being updated in the past 2 years. So let's create our own simple image

https://jekyllrb.com/docs/installation/#requirements
* ruby 2.50 and higher
* rubygems
* gcc and make

Let's create a Dockerfile that satisfys these requirements. Since we have some docs for ubuntu, we'll start with a ubunut base image

```Dockerfile
FROM ubuntu

RUN .....   
```

EXPLAIN WHY WE HAVE A VOLUME

Build the image

```bash
docker build -t ovski/jekyll .
```

Now let's create a new Jekyll site. We'll map the folder on your host to the /var folder within the container (this is purely arbitrary)

```
docker run -v $(pwd):/var ovski/jekyll jekyll new myblog
```

This command will create a folder named `myblog` in your current directory.

And finally let's build the site and make it available on a local server. 

```bash
docker run -w /var/myblog -p 4000:80 -v $(pwd):/var ovski/jekyll bundle exec jekyll serve
```

What does this command do? --> to explain

Ouch an error

```
bundler: failed to load command: jekyll (/usr/local/bundle/bin/jekyll)
/usr/local/bundle/gems/bundler-2.5.15/lib/bundler/definition.rb:594:in `materialize': Could not find minima-2.5.1, jekyll-feed-0.17.0, jekyll-seo-tag-2.8.0, rexml-3.3.1, strscan-3.1.0, bigdecimal-3.1.8, rake-13.2.1 in locally installed gems (Bundler::GemNotFound)
```

Looks like the gems are not installed. Let's update the command to install them before serving.

Let's try 

```bash
docker run -w /srv/myblog -p 4000:80 -v $(pwd):/srv ovski/jekyll sh -c "bundle install && bundle exec jekyll serve"
```

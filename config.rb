require 'less'
require 'colorize'
require 'lib/blog_helpers'

commonDirectory = File.join(File.dirname(__FILE__), "..", 'developer-center-common')

if Dir.exists? commonDirectory
    files.watch :source, path: File.join(commonDirectory, "source")
    files.watch :data, path: File.join(commonDirectory, "data")

    require File.join(commonDirectory, "lib/config_helpers")
    require File.join(commonDirectory, "lib/custom_md/jsonresponse.rb")

    set :markdown, input: "GFM" #
    set :markdown, input: "KramdownJsonResponse"

    page "*", :layout => :blog

    helpers CustomHelpers
else
    puts "Sibling directory 'developer-center-common' is not present".red

    page "*", :layout => :default
end

set :relative_links, true

set :is_sub_site, true
set :sub_site_nav_root, [{
    :title => 'Blog',
    :url => "/blog/"
}]

helpers BlogHelpers



###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false
page '/javascript/search.js', layout: false

activate :syntax, :wrap => 'true'
activate :directory_indexes

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  #blog.prefix = "blog"

  #blog.permalink = "blog/{year}/{month}/{day}/{title}/"
  # Matcher for blog source files
  blog.sources = "{year}-{month}-{day}-{title}/index.html"
  # blog.taglink = "tags/{tag}.html"
  # blog.layout = "layout"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  #blog.default_extension = ".md"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  # blog.paginate = true
  # blog.per_page = 10
  # blog.page_link = "page/{num}"
end

configure :development do
  activate :livereload
end

set :build_dir, 'localBuild'
set :js_dir, "javascript"

activate :asset_host, :host => ENV["CDN_URL"] || "/"

page "/feed.xml", layout: false

# Build-specific configuration
configure :build do
    ignore /stylesheets\/(?!styles).*\.less/
    ignore /stylesheets\/lib\/less\/*/
end

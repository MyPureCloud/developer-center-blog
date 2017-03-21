require "lib/tag_cloud"

module BlogHelpers
    def _get_path(current_page)
        "https://developer.mypurecloud.com/blog#{current_page.url}"
    end
    def email_share_link(current_page)
        "mailto:?&subject=#{current_page.metadata[:page][:title]}&body=#{_get_path(current_page)}"
    end

    def twitter_share_link(current_page)
        message = "#{current_page.metadata[:page][:title]} #{_get_path(current_page)} via @PureCloud_Dev"

        "https://twitter.com/home?status=#{URI.escape(message)}"
    end

    def google_share_link(current_page)
        "https://plus.google.com/share?url=#{_get_path(current_page)}"
    end

    def linkedin_share_link(current_page)
        "https://www.linkedin.com/shareArticle?mini=true&url=#{_get_path(current_page)}&title=#{URI.escape(current_page.metadata[:page][:title])}&summary=&source="
    end

    def get_blog_author(email)

        allAuthors = data.authors

        allAuthors.each do |author|
            if
                author.imagename = "authorimages/" + email.gsub(/\W/, '') + ".png"
                return author if author.email == email
            end
        end

        return nil
    end

    def tag_cloud(options = {})
        [].tap do |html|
            TagCloud.new(options).render(blog.tags) do |tag, size, unit|
                html << link_to(tag, "/blog" + tag_path(tag), style: "font-size: #{size}#{unit}")
            end
        end.join(" ")
    end

    def raise_error(message)
        puts message.red
        raise message
    end

    def lint_page(current_page)

        #check page for required properties
        [:title, :date, :tags, :author].each do |property|
            raise_error("Blog page '#{current_page.metadata[:page][:title]}' is missing property #{property}.  See 'Required Properties' section of the README") if current_page.metadata[:page][property] == nil
        end

        #validate author config
        author_email = current_page.metadata[:page][:author]

        #validate email address
        raise_error("Author email address is in an incorrect format" ) unless author_email =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

        author_data = get_blog_author author_email

        raise_error("Author data not found in data/authors.yml" ) if author_data == nil

        [:email, :name, :bio].each do |property|
            raise_error("Author profile is missing property #{property}.  See 'Author Bios' section of the README") if author_data[property] == nil
        end

        raise_error("Author image '#{author_data.imagename}' not found in source/authors" ) unless File.exists?(File.join(File.dirname(__FILE__), "..", 'source/', author_data.imagename))

        return

    end
end

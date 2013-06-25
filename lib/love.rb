require 'bundler'
require 'erb'

class Love

  TEMPLATE =<<EOF
<!DOCTYPE html>
<html>
  <head>
    <title>Thank you all, guys and girls!!! Luv u!</title>
  </head>
  <body>
    <%= thanks %>
  </body>
</html>
EOF
  THANKS =<<EOF
<div class='thank-you'>
  I'd like to thank <b><%= who %></b> for creating and maintaining <b><%= what %></b>.
  I wanna hug you someday and say in person what great job you done!
  <%= '<3' * rand(10) %>
</div>
EOF
  THANKS_CONTRIB =<<EOF
<br><br><br>
<div class='thank-you contributors'>
  <%= '<3' * rand(10) %>
  Also I want to thank all contributors, who post issues and send pull requests! Wihtout you this <=% what %> can not be so awesome!
  <%= contributors %>
  <%= '<3' * rand(10) %>
</div>
EOF

  TEMPLATE_MD =<<EOF
### Thank you all, guys and girls!!! Luv u!</title>
<%= thanks %>
EOF
  THANKS_MD =<<EOF
I'd like to thank <%= who %> for creating and maintaining <%= what %>.
I wanna hug you someday and say in person what great job you done!
<%= '<3' * rand(10) %>
EOF


  def self.share_for(args)
    by_gemname = args.include? 'by_gem'
    for_site = args.include? 'site'

    self.new by_gemname, for_site
  end

  attr_reader :by_gemname, :for_site, :gems

  def initialize(by_gemname, for_site)
    @by_gemname = by_gemname
    parse_gemfile

    if for_site
      share_for_site
    else
      share_for_gem
    end
  end

  def share_for_site
    title = Love::ThankWords.title_thanks
    styles = ERB.new(File.read(
    thanks = \
      if by_gemname
        thanks_by_gemname
      else
        thanks_by_author
      end
    b = binding
    File.open('./public/love.html', 'w+') do |f|
      f.write ERB.new(TEMPLATE).result(b)
    end
  end

  def share_for_gem
    thanks = \
      if by_gemname
        thanks_by_gemname
      else
        thanks_by_author
      end
    b = binding
    File.open('./LOVE.md', 'w+') do |f|
      f.write ERB.new(TEMPLATE_MD).result(b)
    end
  end

  def parse_gemfile
    Bundler.setup.specs.each do |spec|
      gem = Love::Gem.new(spec)
      @gems << gem
      @authors << gem.authors
    end
    @authors = @authors.flatten.uniq
  end

  def thanks_by_gemname
    thanks = ''
    template = for_site ? THANKS : THANKS_MD
    @gems.each do |gem|
      who = \
        if gem.authors.count > 1
          "these cool and creative people: #{gem.authors.map(&:name).join(', ')}"
        else
          "this cool and creative person #{gem.authors.first.name}"
        end
      what = "this awesome gem - #{gem.name}"
      b = binding
      thanks << ERB.new(template).result(b)
    end
    thanks
  end

  def thanks_by_author
    thanks = ''
    template = for_site ? THANKS : THANKS_MD
    @authors.each do |author|
      who = "my mate #{author.name}"
      what = \
        if author.gems.count > 1
          "these great libraries: #{author.gems.map(&:name).join(', ')}! Wow man! You awesome!"
        else
          "this helpful and useful gem - #{author.gems.first.name}"
        end
      b = binding
      thanks << ERB.new(template).result(b)
    end
    thanks
  end

  # WIP
  def thanks_to_contributors
    thanks = ''
  end

end
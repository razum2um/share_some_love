module Love
  class Author

    attr_reader :name, :info, :gems, :username

    def initialize(name, fetch = true)
      @name = name
      @gems = []
      fetch_info if fetch
    end

    def fetch_info
      uri = ERB::Util.url_encode(name)
      puts "search for #{name}"
      begin
        search_person = Love.octokit.search_users uri
        @info = \
          if search_person.count > 1
            puts '!!! THERE ARE SEVERAL PERSONS WITH THIS NAME IN GITHUB !!!'
            user_num = pick_user(search_person)

            Love.octokit.user search_person[user_num].login
          else
            Love.octokit.user search_person.first.login
          end
        puts "found #{@info.login}"
      rescue Octokit::Forbidden
        puts 'github have some unfair limits =('
      rescue
        puts 'not found'
      end
    end

    def add_gem(gem)
      @gems << gem
    end

    private

    def pick_user(users)
      if Love.check_author
        puts "Please check right man with his number and we'll continue"
      else
        puts "To check author manually please restart with option -v"
      end

      users.each_with_index do |person, index|
        puts "#{index} - name: #{person.name}; login: #{person.login}; username: #{person.username}"
      end

      if Love.check_author
        $stdin.gets.chomp.to_i
      else
        puts "Taken first"
        0
      end
    end

  end
end

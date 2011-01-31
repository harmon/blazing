class Blazing::Target

  attr_accessor :name, :user, :hostname, :path, :recipes, :target_name, :default_target, :repository

  def initialize(name, repository, &block)
    @name = name
    @repository = repository
    instance_eval &block
  end

  def deploy_to(location)
    @user = location.match('(.*)@')[1]
    @hostname = location.match('@(.*):')[1]
    @path = location.match(':(.*)')[1]
  end

  def location
    # TODO: build this together more carefully, checking for emtpy hostname etc...
    @location ||= "#{ @user }@#{ @hostname }:#{ @path }"
  end

  # Only used in global remote for setting default remote
  # TODO: extract into other class, inherit
  def set_default_target(target_name)
    @default_target = target_name
  end
  
  class Setup < Thor

    include Thor::Actions

    def self.source_root
      File.dirname(__FILE__)
    end
    
    argument :target

    desc 'setup:setup_repository TARGET', 'sets up a remote for blazing deployments'
    def setup_repository

      # TODO: Extract into helper
      # remote_with_condition()
    
      command = "if [ -e ~/sites/blazingoverride.ch/ ]; then echo 'repository has been cloned already'; else git clone #{ remote.repository } #{ remote.path } && git config receive.denyCurrentBranch ignore; fi"
      system "ssh #{ remote.user }@#{ remote.hostname } '#{ command }'"
      if $? == 0
        say '--> [ok]', :green
        invoke 'add_pre_receive_hook', remote
      else
        say '--> [FAILED]', :red
        say '[BLAZING] -- ROLLING BACK', :blue
        return
      end
    end

    desc 'setup:clone_repository TARGET', 'sets up a remote for blazing deployments'
    def add_pre_receive_hook
      say 'adding pre-receive hook'
      pre_hook = "deploy/pre-receive"
      template('templates/pre-hook.tt', pre_hook)
      system "chmod +x #{ pre_hook }"
      system "scp #{ pre_hook } #{ remote.user }@#{ remote.hostname }:#{ remote.path }/.git/hooks/"
      say '--> [ok]', :green
      invoke 'add_post_receive_hook', remote
    end

    desc 'setup:clone_repository TARGET', 'sets up a remote for blazing deployments'
    def add_post_receive_hook
      say 'adding post-receive hook'
      post_hook = "deploy/post-receive"
      template('templates/post-hook.tt', post_hook)
      system "chmod +x #{ post_hook }"
      system "scp #{ post_hook } #{ remote.user }@#{ remote.hostname }:#{ remote.path }/.git/hooks/"
      say '--> [ok]', :green
      invoke 'add_remote', remote
    end
    
    desc 'setup:add_remote TARGET', 'adds a git remote for the given remote'
    def add_remote
      say 'adding remote as remote to repository'
      system "git remote add #{ remote.name } #{ remote.user }@#{ remote.hostname }:#{ remote.path }"
    end

  end

end
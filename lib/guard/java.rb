require 'guard/guard'

module ::Guard
  class Java < ::Guard::Guard
    def initialize(watchers=[], options={})
      super
      @options = {
        :all_after_pass     => true,
        :all_on_start       => true,
        :test_runner_class  => 'org.junit.runner.JUnitCore',
        :project_name       => 'Java Project',
        :focused_cli        => nil,
        :all_cli            => nil,
        :classpath          => '.'
      }.merge(options)
    end

    def start
      UI.info 'Guard::Java is running'
      raise ArgumentError, ":focused_cli and :all_cli options must be set" if @options[:focused_cli].nil? || @options[:all_cli].nil?

      run_all if @options[:all_on_start]
    end

    def run_all
      project_name = @options[:project_name]
      notify project_name, "Build and run all", :pending
      result = do_shell(all_command)
      result_description = "#{project_name} build results"
      notify result_description, "Build #{result.to_s.capitalize}", result # Notify of success or failure
    end

    def run_on_changes(classes)
      run_focused_tests(classes)
    end

    def stop
    end

    def run_focused_tests(classes)
      project_name = @options[:project_name]
      klass = classes[0]

      notify "Running tests in #{klass}", "#{project_name} file change detected", :pending  # notify any interested listeners
      result = do_shell(focused_command)
      result = run_test_class(klass) unless result == :failed
      result_description = "#{project_name}: test run for #{klass}"

      notify result_description, "Build #{result.to_s.capitalize}", result # Notify of success or failure

      if result == :success && @options[:all_after_pass]
        run_all
      end
      nil
    end

    def focused_command
      @options[:focused_cli]
    end

    def all_command
      @options[:all_cli]
    end

    def notify(msg, title='', image=nil)
      Notifier.notify(msg, title: title, image: image)
    end

    def do_shell(command)
      IO.popen(command) do |out|
        until out.eof?
          puts out.gets
        end
      end

      code = $?  # Get the status code of the last-finished process
      (code == 0) ? :success : :failed
    end


    def run_test_class(klass)
      test_command = "java -cp #{options[:classpath]} #{options[:junit_runner_class]} #{klass}"
      puts test_command
      do_shell test_command
    end
  end

end


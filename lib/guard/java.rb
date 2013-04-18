require 'guard/guard'

module ::Guard
  class Java < ::Guard::Guard
    def initialize(watchers=[], options={})
      super
      @options = {
        :all_after_pass     => true,
        :all_on_start       => true,
        :junit_runner_class => 'org.junit.runner.JUnitCore',
        :project_name       => 'Java Project',
        :focused_cli        => '',
        :all_cli            => '',
        :classpath          => ''
      }.merge(options)
    end

    def start
      UI.info 'Guard::Java is running'
      run_all if @options[:all_on_start]
    end

    def run_all
      invoke_java
    end

    def run_on_changes(paths)
      invoke_java(paths)
    end

    def stop
    end

    def invoke_java(paths=[])
      no_file = (paths.size == 0)
      project_name = @options[:project_name]
      path = no_file ? project_name : paths[0]
      result_description = ''

      if no_file
        notify project_name, "Build and run all", :pending
        result = do_shell(all_command)
        result_description = "#{project_name} build results"
      else
        notify "Running tests in #{path}", "#{project_name} file change detected", :pending  # notify any interested listeners
        result = do_shell(focused_command)
        result = test_file(path) unless result == :failed
        result_description = "#{project_name}: test run for #{path}"
      end

      notify result_description, "Build #{result.to_s.capitalize}", result # Notify of success or failure

      if result == :success && @options[:all_after_pass] && !no_file
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


    def test_file(path)
      klass = path.gsub('src/', '').gsub('/', '.').gsub('.java', '')
      test_command = "java -cp #{options[:classpath]} #{options[:junit_runner_class]} #{klass}"
      puts test_command
      do_shell test_command
    end
  end

end


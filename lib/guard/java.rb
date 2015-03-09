require 'guard/compat/plugin'

module Guard
  class Java < Plugin

    def initialize(options={})
      super
      @options = {
          all_after_pass:               true,
          all_on_start:                 true,
          source_directory:               '',
          focused_after_compile:        true,
          test_runner_class:            'org.junit.runner.JUnitCore',
          project_name:                 'Java Project',
          focused_compile_cli_command:  nil,
          all_compile_cli_command:      nil,
          classpath:                    '.'
      }.merge(options)
    end

    def start
      UI.info 'Guard::Java is running'
      raise ArgumentError, ':focused_cli and :all_cli options must be set' if @options[:focused_compile_cli_command].nil? || @options[:all_compile_cli_command].nil?
      run_all if @options[:all_on_start]
    end

    def run_all
      project_name = @options[:project_name]
      notify project_name, 'Build and run all', :pending
      result = do_shell(all_command)
      result_description = "#{project_name} build results"
      notify result_description, "Build #{result.to_s.capitalize}", result # Notify of success or failure
    end

    def run_on_changes(classes)
      project_name = @options[:project_name]
      klass = classes[0]

      result = compile(project_name, klass)
      result = run_focused_tests(project_name, klass) if result != :failed && @options[:focused_after_compile]
      result_description = "#{project_name}: test run for #{klass}"
      notify result_description, "Build #{result.to_s.capitalize}", result # Notify of success or failure

      if result == :success && @options[:all_after_pass]
        run_all
      end
      nil
    end

    def compile(project_name, klass)
      notify "Compiling because of #{klass} change", "#{project_name} file change detected", :pending  # notify any interested listeners
      klass_path = klass.dup
      klass_path.gsub! '.', '/'
      UI.info "running #{focused_compile_command(klass)}"
      do_shell(focused_compile_command(klass_path))
    end

    def focused_compile_command(klass)
      "#{@options[:focused_compile_cli_command]}#{@options[:source_directory]}#{klass}.java"
    end

    def run_focused_tests(project_name, klass)
      notify "Running focused tests because of #{klass} change", "#{project_name} file change detected", :pending  # notify any interested listeners
      unless klass.end_with? 'Test'
        klass << 'Test'
      end
      run_test_class(klass)
    end

    def run_test_class(klass)
      test_command = "java -cp #{options[:classpath]} #{options[:test_runner_class]} #{klass}"
      UI.info "running test command #{test_command}"
      do_shell test_command
    end

    def all_command
      @options[:all_compile_cli_command]
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

  end
end


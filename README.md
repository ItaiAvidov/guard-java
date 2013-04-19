# Guard::Java

This guard allows you to build and test your Java code automatically when files are altered.


## Install

Install the gem with:

    gem install guard-java

Or add it to your Gemfile:

    gem 'guard-java'

And then add a basic setup to your Guardfile:

    guard init java


## Usage

If you can do something in your shell, or in Ant, you can do it when a file changes
with guard-java.

You simply provide paths to watch, including how to map a class to it's unit-test class name
and some other options.


### Examples

``` ruby
require 'guard/java_translator'

guard :java,  :project_name   => 'My Java Project',
              :all_after_pass => false,                   # run the all_cli command if the specific test class passes (true/false)
              :focused_cli    => 'ant clean debug',       # (required) command-line to run before running a specific test class
              :all_cli        => 'ant package-and-test',  # (required) command-line to run that executes the "build and run all tests" concept
              :classpath      => './bin/classes.jar:./libs/*:/usr/share/java/junit.jar' # (required) don't forget junit and your own jars here
            # :all_on_start   => true                     # run all on startup of guard
            # :test_runner_class => 'org.junit.runner.JUnitCore' # just in case you're using junit 3 or something other than 4
  do

  watch (%r{^tests/src/*/(.+)\.java$}) { |m| ::Guard::JavaTranslator.filename_to_classname(m[0]) }  # test file changes

  watch(%r{^src/*/(.+)\.java$}) { |m|
    test_filename = "tests/src/#{m[1]}Test.java"
    ::Guard::JavaTranslator.filename_to_classname(test_filename)
  } # when source files change, run the test for that file

  # ignore(path) will ignore files that change automatically, such as generated code files
end
```


### Using Guard

From the project's root directory, simply run:

```shell
$ guard
20:28:01 - INFO - Guard uses GNTP to send notifications.
20:28:01 - INFO - Guard uses Tmux to send notifications.
20:28:01 - INFO - Guard uses TerminalTitle to send notifications.
20:28:01 - INFO - Guard::Java is running
20:28:01 - INFO - Guard is now watching at '/Users/tchype/Projects/some_java_project'
[1] guard(main)>
```

It tells you what notification methods it will use to tell you when it has detected changes,
when it is building/testing, and whether those things have succeeded or failed.  In the example 
above, I am running Growl as my system notifier and Tmux as my Terminal Multiplexer within 
Mac OSX's Terminal program.

You can see that it detected those things and is using GNTP to send Growl notifications
(popups with detailed messages), Tmux color coding (Yellow for building/testing, Red for 
failures, and Green for success), as well as updating the Terminal window/tab's title
when guard detects a change.



### Other Useful Tips
#### Working with Android
The template Guardfile you get when you run ```guard init``` has some samples in it.  You will want to include your Android SDK jar
file in the ```classpath``` argument.  You can write a ruby function that reads it from a local or project
properites file that you call when setting your classpath.  For example:

```ruby
require 'guard/java_translator'

def android_sdk_dir
  sdk_dir = ''
  %w{project.properties local.properties}.each do |prop_file|
    File.open(File.join(File.dirname(__FILE__), prop_file)).each do |line|
      sdk_dir = line[8..-1] if line[0..7] == 'sdk.dir='
    end
  end

  sdk_dir.strip
end

guard :java,  :project_name   => 'Search SDK',
              :all_on_start   => false,
              :all_after_pass => false,
              :focused_cli    => 'ant guard-debug',
              :all_cli        => 'ant clean debug',
              :classpath      => "/bin/classes.jar:./libs/*:/usr/share/java/junit.jar:#{android_sdk_dir}/android-10/*" do

  ignore(%r{^src/com/infospace/some_project/BuildTimeUpdatedFile.java}) # Build-time code-gen

  watch (%r{^tests/src/com/infospace/some_project/*/(.+)\.java$})  { |m|
    ::Guard::JavaTranslator.filename_to_classname(m[0])
  } # Test file changes

  watch(%r{^src/com/infospace/some_project/*/(.+)\.java$}) { |m|
    test_filename = "tests/src/com/infospace/some_project/#{m[1]}Test.java"
    ::Guard::JavaTranslator.filename_to_classname(test_filename)
  } # when source files change, run the test for that file
end
```

*note: The android jar path must go after the junit.jar path in the classpath, or you will get an exception about ```no method "main"```
and method Stub message.  Android only stubs out the JUnitCore runner logic, and if the android jar is placed earlier in the path,
it won't be able to run any tests.*

#### Latency
In the case where many files are changing close together (e.g., saving a test file and saving the class under test), you can tell
guard to wait a certain number of seconds when it detects a file change before triggering a test cycle using the
```--latency``` (or ```-l```) command line option.  For example, to wait 10 seconds after a change is detected for other changes
to also accumulate:


```shell
$ guard -l 10
```

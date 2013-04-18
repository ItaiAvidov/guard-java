# Guard::Java

This little guard allows you to build and test your Java code automatically when files are altered.


## Install

Make sure you have [guard](http://github.com/guard/guard) installed.

Install the gem with:

    gem install guard-java

Or add it to your Gemfile:

    gem 'guard-java'

And then add a basic setup to your Guardfile:

    guard init java


## Usage

If you can do something in your shell, or in Ant, you can do it when a file changes
with guard-java.

You simply provide paths to watch, including how to map a class to it's unit-test filename
and some other options.

``` ruby
guard :java,  :project_name   => 'My Java Project',
              :all_after_pass => false,                   # run the all_cli command if the specific test class passes (true/false)
              :focused_cli    => 'ant clean debug',       # (required) command-line to run before running a specific test class
              :all_cli        => 'ant package-and-test',  # (required) command-line to run that executes the "build and run all tests" concept
              :classpath      => './bin/classes.jar:./libs/*:/usr/share/java/junit.jar' # (required) don't forget junit and your own jars here
            # :all_on_start   => true                     # run all on startup of guard
            # junit_runner_class => 'org.junit.runner.JUnitCore' # just in case you're using junit 3 or something other than 4
  do

  watch (%r{^tests/src/*/(.+)\.java$})  # test file changes
  watch(%r{^src/*/(.+)\.java$}) { |m| "tests/src/#{m[1]}Test.java" } # when source files change, run the test for that file
  # ignore(path) will ignore files that change automatically, such as generated code files
end
```


### Examples

``` ruby
guard :java,  :project_name   => 'My Java Project',
              :all_after_pass => false,                   # run the all_cli command if the specific test class passes (true/false)
              :focused_cli    => 'ant clean debug',       # (required) command-line to run before running a specific test class
              :all_cli        => 'ant package-and-test',  # (required) command-line to run that executes the "build and run all tests" concept
              :classpath      => './bin/classes.jar:./libs/*:/usr/share/java/junit.jar' # (required) don't forget junit and your own jars here
            # :all_on_start   => true                     # run all on startup of guard
            # junit_runner_class => 'org.junit.runner.JUnitCore' # just in case you're using junit 3 or something other than 4
  do

  watch (%r{^tests/src/*/(.+)\.java$})  # test file changes
  watch(%r{^src/*/(.+)\.java$}) { |m| "tests/src/#{m[1]}Test.java" } # when source files change, run the test for that file
  # ignore(path) will ignore files that change automatically, such as generated code files
end
```

### Other Useful Tips
In the case where many files are changing close together (e.g., saving a test file and saving the class under test), you can tell 
guard to wait a certain number of seconds when it detects a file change before triggering a test cycle using the
```--latency``` (or ```-l```) command line option.  For example, to wait 10 seconds after a change is detected for other changes
to also accumulate:


```shell
$ guard -l 10
```

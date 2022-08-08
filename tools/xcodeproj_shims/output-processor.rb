#!/usr/bin/env ruby
STDOUT.sync = true
BAZEL_WORKSPACE = ENV['BAZEL_WORKSPACE_ROOT'].freeze

class BazelOutputLine
  attr_reader :text

  def initialize(line)
    # Otherwise we might get `invalid byte sequence in US-ASCII (ArgumentError)` during matching with regex
    @text = line.encode("US-ASCII", invalid: :replace, undef: :replace, replace: '')
  end

  # Try to create a processed line based on a match rule, or a pass-through
  def self.from(line)
    if (message_line = CompilerMessageLine.create_from(line))
      message_line
    elsif (starlark_line = StarlarkLine.create_from(line))
      starlark_line
    else
      BazelOutputLine.new(line)
    end
  end
end

class RegexMatchLine < BazelOutputLine
  attr_reader :regex, :match_data

  @regex = nil
  @match_data = nil

  def self.create_from(line)
    rule = new(line)

    rule.match_data.nil? ? nil : rule
  end
end

class StarlarkLine < RegexMatchLine
  def initialize(line)
    @regex = /^(DEBUG|ERROR): (.+(.bzl|.bazel))(:\d+:\d+): (.+)$/

    super(line)

    return unless (@match_data = @text.match(@regex))

    message_type, starlark_file, file_ext, file_line, message = @match_data.captures

    message_type = case message_type
                   when 'DEBUG'
                     'warning'
                   when 'ERROR'
                     'error'
                   end

    @text = "#{starlark_file}#{file_line}: #{message_type}: #{message}"
  end
end

class CompilerMessageLine < RegexMatchLine
  def initialize(line)
    @regex = /^(.+execroot\/[^\/]+\/)(.+:) (error:|warning:|note:) (.+)/

    super(line)

    return unless (@match_data = @text.match(@regex))

    _, file_path, error_level, message = match_data.captures
    expanded_file_path = File.expand_path(file_path, BAZEL_WORKSPACE)

    full_output = "#{expanded_file_path} #{error_level} #{message}"
    @text = full_output
  end
end

if BAZEL_WORKSPACE.nil? || BAZEL_WORKSPACE.empty?
  raise "ERROR: Missing 'BAZEL_WORKSPACE_ROOT'"
end

while (raw_input = gets)
  output = BazelOutputLine.from(raw_input)
  puts output.text
end

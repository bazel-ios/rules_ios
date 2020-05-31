#!/usr/bin/env ruby

BAZEL_WORKSPACE = ENV['BAZEL_WORKSPACE_ROOT'].freeze

# Documentation
class BazelOutputLine
  attr_reader :text

  def initialize(line)
    @text = line
  end

  # Try to create a processed line based on a match rule, or a pass-through
  def self.from(line)
    if (message_line = MessageLine.create_from(line))
      message_line
    elsif (snapshot_line = SnapshotLine.create_from(line))
      snapshot_line
    else
      BazelOutputLine.new(line)
    end
  end
end

# Documentation
class RegexMatchLine < BazelOutputLine
  attr_reader :regex, :match_data

  @regex = nil
  @match_data = nil

  def self.create_from(line)
    rule = new(line)

    rule.match_data.nil? ? nil : rule
  end
end

# Documentation
class SnapshotLine < RegexMatchLine
  def initialize(line)
    @regex = /^DEBUG: .+ Snapshot test (.+) (\(.+\)) does not specify it uses an app host$/

    super(line)

    return unless (@match_data = line.match(@regex))

    test_name, test_path = @match_data.captures
    @text = "warning: Snapshot test #{test_name} #{test_path} does not specify it uses an app host"
  end
end

# Documentation
class MessageLine < RegexMatchLine
  def initialize(line)
    @regex = /^(.+:) (error:|warning:|note:) (.+)/

    super(line)

    return unless (@match_data = line.match(@regex))

    file_path, error_level, message = match_data.captures
    full_file_path = "#{BAZEL_WORKSPACE}/#{file_path}"

    full_output_line = "#{full_file_path} #{error_level} #{message}"
    @text = full_output_line
  end
end

if BAZEL_WORKSPACE.nil? || BAZEL_WORKSPACE.empty?
  raise "ERROR: Missing 'BAZEL_WORKSPACE_ROOT'"
end

while (raw_input = gets)
  output = BazelOutputLine.from(raw_input)
  puts output.text
end

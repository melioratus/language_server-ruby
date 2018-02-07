require "test_helper"

module LanguageServer::Linter
  class RubyWCTest < Minitest::Test
    def test_error
      linter = RubyWC.new(<<-EOS.strip_heredoc)
        require "foo
        if a == "\\n"
      EOS

      # <compiled>:2: syntax error, unexpected $undefined, expecting end-of-input
      # if a == "\n"
      #           ^

      if Gem::Version.new(Ruby::VERSION) >= Gem::Version.new('2.5.0')
        characters = 9..10
      else
        characters = 10..11
      end

      assert {
        linter.call == [Error.new(line_num: 1, characters: characters, message: "unexpected $undefined, expecting end-of-input", type: "syntax error")]
      }
    end

    def test_warn
      linter = RubyWC.new(<<-EOS.strip_heredoc)
        a = 1
      EOS

      assert {
        linter.call == [Error.new(line_num: 0, characters: 0..4, message: "assigned but unused variable - a", type: "warning")]
      }
    end
  end
end

# frozen_string_literal: true

require "stringio"
require_relative "test_helper"

class TerminalInputTest < Minitest::Test
  def test_reads_letter_keys
    assert_equal :w, read("w")
    assert_equal :a, read("A")
    assert_equal :q, read("q")
  end

  def test_reads_interaction_keys
    assert_equal :enter, read("\r")
    assert_equal :enter, read("\n")
    assert_equal :space, read(" ")
  end

  def test_reads_legacy_arrow_keys
    assert_equal :up, read("\e[A")
    assert_equal :down, read("\e[B")
    assert_equal :right, read("\e[C")
    assert_equal :left, read("\e[D")
  end

  def test_reads_modified_csi_arrow_keys
    assert_equal :up, read("\e[1;2A")
    assert_equal :left, read("\e[1;5D")
  end

  def test_reads_ss3_arrow_keys
    assert_equal :up, read("\eOA")
    assert_equal :right, read("\eOC")
  end

  def test_bare_escape_is_a_real_event
    assert_equal :escape, read("\e")
  end

  def test_ctrl_c_maps_to_quit_event_in_raw_mode
    assert_equal :q, read("\u0003")
  end

  def test_unknown_escape_sequence_is_ignored
    assert_nil read("\e[15~")
  end

  private

  def read(bytes)
    input = StringIO.new(bytes)
    Sunbird::Host::TerminalInput.new(
      input: input,
      escape_timeout: 0
    ).read_event
  end
end

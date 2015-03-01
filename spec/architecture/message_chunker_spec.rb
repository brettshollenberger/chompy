require "spec_helper"

describe MessageChunker do
  before(:each) do
    @text = <<-eos
      Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor 
      incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud 
      exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute 
      irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla 
      pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia
      deserunt mollit anim id est laborum.
    eos

    @chunks = MessageChunker.new(chunk_size: 20).chunk(@text)
  end

  it "chunks messages into groups of a specified length" do
    @chunks[0..-2].each do |chunk|
      expect(chunk[:message].length).to eq 20
    end

    expect(@chunks.last[:message].length).to be_between(1, 20).inclusive
  end

  it "counts the number of chunks" do
    expect(@chunks.first[:number]).to eq 1
    expect(@chunks.second[:number]).to eq 2
    expect(@chunks.first[:total]).to eq @chunks.length
  end

  it "adds special positional markers to the first and last chunks" do
    expect(@chunks.first[:position]).to  eq :first
    expect(@chunks.second[:position]).to be_nil
    expect(@chunks.last[:position]).to   eq :last
  end
end

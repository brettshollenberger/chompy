require "spec_helper"

describe WebRequest::UrlStandardizer do
  it "adds http as the default url scheme" do
    expect(WebRequest::UrlStandardizer.standardize("google.com")).to eq "http://google.com"
  end

  it "does not overwrite scheme" do
    expect(WebRequest::UrlStandardizer.standardize("https://google.com")).to eq "https://google.com"
  end
end

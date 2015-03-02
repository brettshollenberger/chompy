require "spec_helper"

describe WebRequest do
  context "When the request is successful" do
    before(:each) do
      stub_request(:get, "http://www.example.com/").
        with(:headers => {
        'Accept'=>'*/*', 
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 
        'User-Agent'=>'Ruby'
      }).
      to_return(
        :status => 200, 
        :body => "<p>This is an example.</p>", 
        :headers => {}
      )
    end

    it "makes web requests" do
      expect(WebRequest.make(:get, "http://www.example.com")).to eq("<p>This is an example.</p>")
    end
  end

  context "Request errors" do
    context "When the request times out" do
      before(:each) do
        allow(WebRequest.circuit_breaker).
          to receive(:do_call).and_raise(Timeout::Error)
      end

      it "remakes the request until max attempts are exceeded" do
        unsuccessful_requests = 0

        expect(WebRequest).to receive(:make_attempt).exactly(4).times.and_call_original

        expect {
          WebRequest.make(:get, "http://www.example.com") do
            on_unsuccessful_request do |unsuccessful_request|
              unsuccessful_requests += 1
            end
          end
        }.to raise_error

        expect(unsuccessful_requests).to eq 2
      end

      it "calls handler on invalid request" do
        expect { WebRequest.make(:get, "http://www.example.com") }.to raise_error 
          WebRequest::MaxAttemptsExceeded
      end
    end

    context "When a bad request is made" do
      it "raises InvalidRequest" do
        expect { WebRequest.make(:get, "fake.unreal") }.to raise_error 
          WebRequest::InvalidRequest
      end
    end

    context "HTTP Error Codes" do
      it "bubbles up 400 errors" do
        stub_request(:get, "http://www.example.com/").
          with(:headers => {
            'Accept'=>'*/*', 
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 
            'User-Agent'=>'Ruby'
          }).
          to_return(
            :status => 400, 
            :body => "Unauthorized", 
            :headers => {}
          )

        expect { WebRequest.make(:get, "http://www.example.com") }.to raise_error HTTParty::Error
      end

      it "retries on 500 errors until successful"do
        stub_request(:get, "http://www.example.com/").
          with(:headers => {
            'Accept'=>'*/*', 
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 
            'User-Agent'=>'Ruby'
          }).
          to_return(
            :status => 500, 
            :body => "Unauthorized", 
            :headers => {}
          )

        expect { WebRequest.make(:get, "http://www.example.com") }.to raise_error 
          WebRequest::MaxAttemptsExceeded
      end
    end
  end
end

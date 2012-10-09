require 'spec_helper'

describe PayPal::SDK::Core::NVP do
  
  NVP = PayPal::SDK::Core::NVP
  ConvertCurrencyParams = {
          "baseAmountList"        => { "currency" => [ { "code" => "USD", "amount" => "2.0"} ]},
          "convertToCurrencyList" => { "currencyCode" => ["GBP"] } }
  
  it "create nvp client with prefix url" do
    client = NVP.new("AdaptivePayments")
    client.uri.path.should match "AdaptivePayments$"
  end
  
  it "make AdaptivePayments API request" do
    client   = NVP.new("AdaptivePayments")
    response = client.request("ConvertCurrency", ConvertCurrencyParams)
    response.should_not be_nil
    response["responseEnvelope"].should_not be_nil
    response["responseEnvelope"]["ack"].should eql "Success"
  end
  
  describe "Failure request" do
    
    def should_be_failure(response, message)
      response.should_not be_nil
      response["responseEnvelope"].should_not be_nil
      response["responseEnvelope"]["ack"].should eql "Failure"
      response["error"][0]["message"].should match message            
    end
    
    it "invalid 3 token authentication" do
      client   = NVP.new("AdaptivePayments", :username => "invalid")
      response = client.request("ConvertCurrency", ConvertCurrencyParams )
      should_be_failure(response, "Authentication failed")
    end
    
    it "invalid ssl certificate authentication" do
      client   = NVP.new("AdaptivePayments", :with_certificate, :username => "invalid")
      response = client.request("ConvertCurrency", ConvertCurrencyParams )
      should_be_failure(response, "Authentication failed")
    end

    it "invalid end point" do
      client   = NVP.new("https://svcs-invalid.sandbox.paypal.com/AdaptivePayments")
      response = client.request("ConvertCurrency", ConvertCurrencyParams )
      should_be_failure(response, "No such host is known")
    end
    
    it "with soap endpoint" do
      client   = NVP.new("https://api-3t.sandbox.paypal.com/2.0/")
      response = client.request("ConvertCurrency", ConvertCurrencyParams )
      should_be_failure(response, "Not Found")      
    end
    
    it "invalid service" do
      client   = NVP.new("InvalidService")
      response = client.request("ConvertCurrency", ConvertCurrencyParams )
      should_be_failure(response, "An established connection was aborted")
    end
    
    it "invalid action" do
      client   = NVP.new("AdaptivePayments")
      response = client.request("InvalidAction", ConvertCurrencyParams)
      should_be_failure(response, "Internal Server Error")
    end
    
    it "invalid params" do
      client   = NVP.new("AdaptivePayments")
      response = client.request("ConvertCurrency", { "inValidCurrencyParams" => {} })
      should_be_failure(response, "Invalid request parameter")
    end

  end    
  
end
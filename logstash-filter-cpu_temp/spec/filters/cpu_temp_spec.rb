# encoding: utf-8
require_relative '../spec_helper'
require "logstash/filters/cpu_temp"

describe LogStash::Filters::CPU_TEMP do
  subject(:plugin) { LogStash::Filters::CPU_TEMP.new (config) }
  let(:config) { Hash.new }

  let(:doc) { "" }
  let(:event) { LogStash::Event.new("message" => doc) }

  before(:each) do
    plugin.register
  end
  
  describe "Positive Tests - " do

	describe "filter one complete message - " do
		
		let(:doc) { "12-10-2018 11:27:02 32.999" }

		it "should extract timestamp and cpu temperature" do
			plugin.filter(event)
			expect(event.get("@timestamp").to_f).to eq(1539343622.0)
			expect(event.get("temperature")).to eq(32.999)
			expect(event.get("message")).to eq("12-10-2018 11:27:02 32.999")
		end
	end

	describe "filter another complete message - " do
		let(:doc) { "24-12-2018 22:58:42 0.321" } 
		
		it "should extract timestamp" do
			plugin.filter(event)
			expect(event.get("@timestamp").to_f).to eq(1545692322.0)
			expect(event.get("temperature")).to eq(0.321)
			expect(event.get("message")).to eq("24-12-2018 22:58:42 0.321")
		end
	end 
  end # end Positive Tests
  
  describe "Negative Tests - " do

	describe "filter a wrong datetime format - " do
		
		let(:doc) { "12-50-2018 11:27:02 32.999" }

		it "set a debuginfo field" do
			plugin.filter(event)
			expect(event.get("debuginfo")).to eq("Failed to parse date <12-50-2018 11:27:02>")
			expect(event.get("message")).to eq("12-50-2018 11:27:02 32.999")
		end
	end

	describe "filter a wrong formatted cpu temperature - " do
		
		let(:doc) { "12-10-2018 11:27:02 32,999" }

		it "set a debuginfo field" do
			plugin.filter(event)
			expect(event.get("debuginfo")).to eq("cannot read cpu temperature")
			expect(event.get("message")).to eq("12-10-2018 11:27:02 32,999")
		end
	end
  end # end Negative Tests

end # LogStash::Filters::CPU_TEMP

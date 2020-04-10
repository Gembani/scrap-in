require 'spec_helper'

describe ScrapIn::Tools do
  let(:subject) do 
    class Subject 
      include ScrapIn::Tools
    end.new
  end
  it 'does something' do
    count = 0
    subject.check_until(5) do 
      count = + 1
      true
    end
    expect(count).to eq(1)
  end
end
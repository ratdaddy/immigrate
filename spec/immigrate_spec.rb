require 'spec_helper'

describe Immigrate do
  it 'has a version number' do
    expect(Immigrate::VERSION).not_to be nil
  end

  context '.load' do
    it 'exists' do
      expect(described_class).to respond_to(:load)
    end
  end
end

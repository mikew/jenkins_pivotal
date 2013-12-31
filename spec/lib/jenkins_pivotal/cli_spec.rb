require 'spec_helper'

describe JenkinsPivotal::Cli do
  def try_arg(argument, value)
    args = ["--#{argument}", value.to_s]
    described_class.new(args).options[argument].should == value
  end

  it 'takes --token' do
    try_arg :token, 'ASDF'
  end

  it 'takes --project' do
    try_arg :project, 1234
  end

  it 'takes --message' do
    try_arg :message, 'Message'
  end

  it 'takes --file' do
    try_arg :file, '/a/b/c'
  end

  it 'takes --url' do
    try_arg :url, 'http://example.com/%s'
  end

end

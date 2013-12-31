require 'spec_helper'

describe JenkinsPivotal::Agent do
  subject do
    described_class.new(
      token: 'asdf',
      project: '1234',
      message: '%{foo}',
      url: 'http://example.com/%s',
      file: fixture_path('example-message')
    )
  end

  let(:entry) { JenkinsPivotal::ChangelogEntry.new read_fixture('single-entry') }

  before do
    subject.stub(:current_entry).and_return entry
  end

  its(:token)         { should == 'asdf' }
  its(:project)       { should == 1234 }
  its(:message)       { should == '%{foo}' }
  its(:file_contents) { should == read_fixture('example-message').strip }
  its(:browser_url)   { should == subject.url % entry.sha1 }

  describe 'with messages' do
    before do
      subject.stub(:env_variables).and_return 'foo' => 'bar'
    end

    it 'converts strings to symbols in message_variables' do
      subject.message_variables[:foo].should == 'bar'
    end

    it 'formats message with ENV' do
      subject.stub(:file).and_return nil
      subject.message_to_post.should == "bar\n\n#{entry.message}"
    end

    it 'formats file with ENV' do
      subject.stub(:message).and_return nil
      subject.message_to_post.should == "bar\n\n#{entry.message}"
    end

    it 'simply posts the commit message when neither exist' do
      subject.stub(:file).and_return nil
      subject.stub(:message).and_return nil
      subject.message_to_post.should == entry.message
    end
  end

  describe 'on run!' do
    subject do
      described_class.new(
        token: 'asdf',
        project: '1234',
        message: 'Message',
        url: 'http://example.com/%s',
        file: fixture_path('single-entry')
      )
    end

    it 'formats the message with message_variables' do
      #subject.should_receive(:notify).with 'asdf', 1234
      #subject.stub(:client).and_return double('Mock Client')
      #p subject.client
    end
  end
end

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

  describe 'with deliveries' do
    it 'can tell when an issue is delivered' do
      single = '[delivers #123]'
      multiple = '[#123 delivered] [deliver #234]'
      complex = '[delivers #123 #234] [#345]'
      none = '[#123] not delivered'

      subject.should_deliver(single).should == [123]
      subject.should_deliver(multiple).should == [123, 234]
      subject.should_deliver(complex).should == [123, 234]
      subject.should_deliver(none).should == []
    end
  end

  describe 'gathering changelogs' do
    let(:env) do
      {
        'JENKINS_HOME' => fixture_path('structures')
      }
    end

    it 'returns the default changelog on first build' do
      stubbed_env = {
        'BUILD_NUMBER' => '1',
        'JOB_NAME' => 'first-run'
      }.merge env

      expected = [ File.join(stubbed_env['JENKINS_HOME'],
        'jobs', stubbed_env['JOB_NAME'],
        'builds', stubbed_env['BUILD_NUMBER'],
        'changelog.xml'
      ) ]

      subject.stub(:env_variables).and_return stubbed_env
      subject.changelog_paths.should == expected
    end

    it 'starts from 1 when the lastSuccessfulBuild is -1' do
      stubbed_env = {
        'BUILD_NUMBER' => '5',
        'JOB_NAME' => 'cloudy'
      }.merge env

      expected = [
        File.join(stubbed_env['JENKINS_HOME'],
          'jobs', stubbed_env['JOB_NAME'],
          'builds', '4',
          'changelog.xml'),

        File.join(stubbed_env['JENKINS_HOME'],
          'jobs', stubbed_env['JOB_NAME'],
          'builds', stubbed_env['BUILD_NUMBER'],
          'changelog.xml'),
      ]

      subject.stub(:env_variables).and_return stubbed_env
      subject.changelog_paths.should == expected
    end
  end
end

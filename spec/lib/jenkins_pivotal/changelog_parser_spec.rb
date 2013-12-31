require 'spec_helper'

describe JenkinsPivotal::ChangelogParser do
  subject { described_class.new fixture_path('changelog.xml') }

  its(:entries)          { should be_an Array }
  its(:'entries.length') { should == 43 }
  its(:data)             { should == read_fixture('changelog.xml') }
end

describe JenkinsPivotal::ChangelogEntry do
  subject { described_class.new read_fixture('single-entry') }

  its(:author)          { should == 'Mike Wyatt <wyatt.mike@gmail.com>' }
  its(:author_name)     { should == 'Mike Wyatt' }
  its(:author_email)    { should == 'wyatt.mike@gmail.com' }
  its(:committer)       { should == 'Joe Smith <joe.smith@gmail.com>' }
  its(:committer_name)  { should == 'Joe Smith' }
  its(:committer_email) { should == 'joe.smith@gmail.com' }
  its(:message)         { should == 'proper user_is_omniscient logic' }
  its(:sha1)            { should == '9682485f5b8c5078548a4094ceab789a48150aa8' }
  its(:tree)            { should == 'f338db9d1ad3a1518f864576f04d1247a908a6bb' }
  its(:parent)          { should == 'd9ddf907ed650d0ef30f2d4cf7610024eb3dd0d0' }
end

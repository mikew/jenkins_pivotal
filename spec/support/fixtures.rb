def read_fixture(filename)
  File.read fixture_path(filename)
end

def fixture_path(filename)
  spec_root = File.expand_path '../../', __FILE__
  File.join spec_root, 'fixtures', filename
end

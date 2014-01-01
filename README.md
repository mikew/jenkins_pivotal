# Jenkins + PivotalTracker

Much like jenkins_tracker, only uses the proper /source_commits endpoint
and will set the owner to an "acceptor" when an issues is marked as
delivered.

## Installation

```bash
gem install jenkins_pivotal
```

## Usage

In Jenkins, add a post build step like:

```
jenkins_pivotal --token a1b2c3 --project 1234 --acceptor-token d4e5f6
```

Help output is as follows.

```
Usage: bin/jenkins_pivotal [options...]
    -t, --token               Tracker API token.
    -p, --project             Tracker Project ID.
    -m, --message             Message to add.
    -f, --file                Read message from file.
    -u, --url                 URL to browse commit.
    -a, --acceptor-token      Tracker token of acceptor.
    -v, --version             Display version information.
    -h, --help                Display this help message.
```

- `--url`: Something like `http://example.com/%s`. It will be formatted
  with the SHA1 of the accompanying commit.
- `--mesage`/`--file`: Add this message above the commit message in
  Pivotal. This is formatted with the ENV, so with EnvInject you can do
  something akin to `--message "This issue has been deployed to
  %{STAGING_URL}"`

Only `--token` and `--project` are required. Use `--acceptor-token` if
you would like to change the owner of issues as they are marked for
delivery.

## Contributing

1. Fork it ( http://github.com/mikew/jenkins_pivotal/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# my slackbot
using in [info-mie-u.slack.com](https://info-mie-u.slack.com/)

# How to build
Haskell-stack is required.

1. `git clone https://github.com/kentahama/slackbot.git && cd slackbot`
2. Save the following YAML setting into `stack.yaml`
3. `stack build`

```yaml
resolver: lts-7.19   # you can change this
packages:
- '.'
- location: https://github.com/kentahama/slack-api/archive/09c048fc3bc700cb8746eca96d9e8774e3e72352.tar.gz
  extra-dep: true
```

# How to execute
1. `cd work`
2. `env SLACK_API_TOKEN=xxx-xxxxxx-xxxxxxxx stack exec slackbot`

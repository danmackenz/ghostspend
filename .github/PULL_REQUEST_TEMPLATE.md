# Pull Request

## What does this PR do?

<!-- Short summary of the change -->

## What leak pattern or problem does this address?

<!-- If this adds a new check, describe the real (or realistic) scenario
that motivates it. If this is a bug fix, describe the bug. -->

## How was this tested?

- [ ] Ran `shellcheck` on any modified `.sh` files with no warnings
- [ ] Ran the modified script(s) manually and confirmed expected output
- [ ] If a skill/agent Markdown file changed, tested it inside a live
      Claude Code session (`/gs-audit` or `/gs-setup`) and confirmed Claude
      follows the updated procedure

## Checklist

- [ ] I've updated `README.md` if this changes usage or installation
- [ ] I've added an entry to `CHANGELOG.md`
- [ ] I've not introduced any network call that isn't behind an explicit
      user confirmation prompt
- [ ] I've not added any check that reads credentials, API keys, or
      `.env` file contents

## Anything else reviewers should know?

<!-- Optional -->

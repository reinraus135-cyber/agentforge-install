# Discord Server Setup

## Server Name
AgentForge

## Channel Structure

### Information
- `#welcome` -- Server rules, getting started links, role selection
- `#announcements` -- Release notes, feature launches, maintenance alerts
- `#changelog` -- Auto-posted from GitHub releases

### Community
- `#general` -- Open discussion
- `#showcase` -- Share what you've built with AgentForge
- `#tips-and-tricks` -- Power-user workflows, custom skills, agent chains

### Support
- `#install-help` -- Windows installer, WSL, macOS, Linux issues
- `#bug-reports` -- Structured bug reports (template in channel pins)
- `#feature-requests` -- Vote on upcoming features

### Verticals
- `#trading-defi` -- Trading pack users
- `#devops` -- CI/CD, infrastructure, deployment
- `#content-creators` -- Content marketing, writing, social media

### Meta
- `#feedback` -- Product feedback, UX suggestions
- `#off-topic` -- Non-product chat

## Roles
- `@Founder` -- You
- `@Pro` -- Verified Pro subscribers (manual or bot-assigned)
- `@Team` -- Team plan members
- `@Lifetime` -- Lifetime members
- `@Community` -- Default role for all members

## Bot Integration
- GitHub webhook bot for `#changelog` (releases + important commits)
- Role assignment bot (verify license key -> assign Pro/Team/Lifetime role)

## Links to Add
- Invite link format: `https://discord.gg/agentforge`
- Add to:
  - `site/src/components/Footer.astro` (already done)
  - `docs/getting-started.md` (add at bottom)
  - `README.md` (badges section)

## Creation Steps
1. Create server at discord.com/app
2. Create channels above
3. Set up roles with colors:
   - Founder: ember (#F97316)
   - Pro: indigo (#4F46E5)
   - Team: moss (#16A34A)
   - Lifetime: purple (#7C82F5)
4. Create permanent invite link
5. Add GitHub webhook integration
6. Pin getting-started message in #welcome

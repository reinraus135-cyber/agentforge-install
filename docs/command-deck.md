# Command Deck

The Command Deck is AgentForge's live agent-monitoring interface. It gives you a persistent
browser window that shows everything Claude Code is doing -- agents, tasks, skills, secrets,
MCP servers, and the terminal -- without having to watch a scrolling terminal.

## What you see

The Command Deck has three panes and a system rail:

| Area | What it shows |
|------|---------------|
| **Pane A** | Active agents and tasks (live event stream) |
| **Pane B** | Installed skills -- browse and inspect what Claude can do |
| **Pane C** | Integrated terminal (Claude Code session output) |
| **System rail** | Secrets, MCP servers, effort level, status line |

## How to open it

### After the Windows installer

Click **"Open Command Deck now"** on the Finish page. That is it.

If you closed the Finish page, use either of the shortcuts the installer created:

- **Start Menu**: Start > AgentForge > Command Deck
- **Desktop**: double-click the Command Deck shortcut

### From the terminal (any platform)

```bash
ecc cockpit
```

This starts the backend server (if it is not already running), then opens your browser to
`http://127.0.0.1:7842`.

## Reopen behavior

**Closing the browser tab does not stop the server.** The backend keeps running in the
background. Just open `http://127.0.0.1:7842` in any browser, or run `ecc cockpit` again --
it detects the server is already up and opens the browser without starting a second process.

**After a reboot**, the server is not running. Use `ecc cockpit` (or the Start Menu / Desktop
shortcut) to relaunch it.

## Command reference

```bash
ecc cockpit               # start (if needed) and open browser
ecc cockpit --status      # show whether the server is running and on what port
ecc cockpit --stop        # stop the server
ecc cockpit --restart     # stop then start
ecc cockpit --no-open     # start without opening the browser
ecc cockpit --install-hooks          # opt-in: wire hooks + status line (prompts for confirmation)
ecc cockpit --install-hooks --yes    # same, skipping the confirmation prompt
```

> **Pro security suite:** enabling or disabling cockpit hooks modifies the Claude settings files
> that the file-integrity monitor (FIM) tracks. Re-baseline after each change with:
> `~/scripts/security/fim-watchdog.sh --init`

## Troubleshooting

### "Port 7842 is already in use"

Another process is holding port 7842. Run:

```bash
ecc cockpit --stop
ecc cockpit
```

If the port is held by a non-AgentForge process, identify it with `lsof -i :7842` (Linux/macOS)
or `netstat -ano | findstr 7842` (Windows) and stop that process first.

### "python3-venv not found" or venv setup fails

Install the missing package:

```bash
sudo apt install python3-venv
```

Then run `ecc cockpit` again.

### Where are the logs?

```
~/.agentforge/cockpit/cockpit.log
```

Tail it with:

```bash
tail -f ~/.agentforge/cockpit/cockpit.log
```

### The browser opens but shows a blank page or "401 Unauthorized"

The token file may be missing or mismatched. Run:

```bash
ecc cockpit --stop
ecc cockpit --setup
ecc cockpit
```

This regenerates the token and restarts cleanly.

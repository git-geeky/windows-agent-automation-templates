# Windows Agent Automation Templates

Generic Windows automation patterns for local agent workflows.

This public extract includes:

- a hidden PowerShell launcher pattern;
- a reusable task wrapper with log files and exit-code capture;
- a scheduled-task XML template;
- a small command guard example;
- parser tests for JSON, XML, PowerShell, and VBScript files.

It intentionally excludes private task names, machine paths, service hostnames,
logs, credentials, and local runtime state.

## Quick Start

```powershell
python -m unittest discover -s tests
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-PowerShellParse.ps1
```

To adapt the task XML, replace placeholders such as `{{TASK_NAME}}`,
`{{SCRIPT_PATH}}`, and `{{USER_ID}}` during your own deployment step. Keep the
filled task XML private unless it has been reviewed as generic.

## Restore Overlay

Machine-specific values can live in an untracked JSON file. Start with
`config/restore.example.json` and keep the filled file outside git.


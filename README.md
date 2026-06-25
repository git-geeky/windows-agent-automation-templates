# Windows Agent Automation Templates

Generic Windows automation patterns for local agent workflows.

This public extract includes:

- a hidden PowerShell launcher pattern;
- a reusable task wrapper with log files and exit-code capture;
- a scheduled-task XML template;
- a small XML renderer for private restore overlays;
- a small command guard example;
- parser tests for JSON, XML, PowerShell, and VBScript files.

It intentionally excludes private task names, machine paths, service hostnames,
logs, credentials, and local runtime state.

## Quick Start

```powershell
python -m unittest discover -s tests
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-PowerShellParse.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\New-AgentTaskXml.ps1 -Manifest .\templates\task.manifest.example.json -Template .\task-xml\AgentTask.template.xml -OutFile .\out\AgentTask.xml
```

To adapt the task XML, replace placeholders such as `{{TASK_NAME}}`,
`{{SCRIPT_PATH}}`, and `{{USER_ID}}` during your own deployment step. Keep the
filled task XML private unless it has been reviewed as generic.

## Restore Overlay

Machine-specific values can live in an untracked JSON file. Start with
`config/restore.example.json` and keep the filled file outside git.

The public renderer accepts only placeholder values from a manifest; it does not
create or register scheduled tasks by itself. Keep generated XML private until it
has been reviewed for host names, paths, account names, and credential material.

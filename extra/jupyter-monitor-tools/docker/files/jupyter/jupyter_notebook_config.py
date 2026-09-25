import os


if 'JUPYTER_PASSWORD' in os.environ:
    c.PasswordIdentityProvider.hashed_password = os.environ['JUPYTER_PASSWORD']

c.ServerApp.ip = '*'
c.ServerApp.root_dir = '/source'
# Terminals open bash: every code block in the courses is POSIX shell, and fish
# rejects the first thing most of them do - `KEY="$VAR"` is a syntax error there.
# fish is still installed for anyone who prefers it interactively.
c.ServerApp.terminado_settings = {
    "shell_command": ["/bin/bash", "-l"]
}

c.LanguageServerApp.language_servers = {
    "jsonnet-language-server": {
        "version": 2,
        "argv": ["jsonnet-language-server", "--stdio"],
        "languages": ["jsonnet"],
        "mime_types": ["text/x-jsonnet"]
    },
    "bash-language-server": {
        "version": 2,
        "argv": ["bash-language-server", "start"],
        "languages": ["bash", "sh"],
        "mime_types": ["text/x-sh", "application/x-sh"]
    },
    "vscode-json-languageserver": {
        "version": 2,
        "argv": ["vscode-json-languageserver", "--stdio"],
        "languages": ["json"],
        "mime_types": ["application/json"]
    },
    "yaml-language-server": {
        "version": 2,
        "argv": ["yaml-language-server", "--stdio"],
        "languages": ["yaml"],
        "mime_types": ["text/x-yaml", "application/x-yaml"]
    }
}

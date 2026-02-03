import os

c.ServerApp.ip = '*'
if 'JUPYTER_PASSWORD' in os.environ:
    c.ServerApp.password = os.environ['JUPYTER_PASSWORD']
c.NotebookApp.open_browser = False

c.ServerApp.root_dir = '/source'

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

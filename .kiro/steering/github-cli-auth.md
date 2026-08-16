# GitHub CLI Authentication

When you need to use the `gh` CLI (e.g. creating issues, PRs), retrieve the user's GitHub token from the VS Code credential helper:

```bash
echo "protocol=https
host=github.com
" | git credential fill 2>/dev/null | grep password | cut -d= -f2
```

Then authenticate:

```bash
echo "<token>" | gh auth login --with-token
```

Do not store or echo the token in responses. Use it only for the immediate `gh` operation.

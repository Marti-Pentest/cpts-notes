## PATH Hijacking

[PATH](http://www.linfo.org/path_env_var.html) is an environment variable that defines the directories the system searches through when looking for an executable.

By prepending `.` (the current directory) to `$PATH`, any binary in our working directory takes precedence over system-wide ones:

```shell
PATH=.:${PATH}
export PATH
echo $PATH
```

### Why this matters in privilege escalation

If a SUID/SGID binary or a root-owned script calls another binary **without an absolute path** (e.g. `service`, `ps`, `id`), the system resolves it through `$PATH` — meaning we can drop a malicious binary with the same name into our current directory and have it executed in the context of root.

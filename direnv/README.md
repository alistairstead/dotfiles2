# direnv

Per-directory environment loading, plus the `use_aws` / `use_gcloud` helpers that
scope cloud context to a project instead of a shell.

`.stowrc` ignores `README.*`, so this file stays in the repo and is never
symlinked into `$HOME`.

## Why

`assume <profile>` exports `AWS_PROFILE` and nothing else — every profile in
`~/.aws/config` resolves through `credential_process`, so no keys enter the
environment. That export lives for the rest of the shell. Starship's `aws` module
renders from `AWS_PROFILE` alone — region only decorates a profile that is
already showing — and never looks at the working
directory, so once you have assumed a role, the prompt advertises AWS in every
directory you visit, including GCP projects.

The prompt is not wrong: those credentials really are live in that shell. What is
missing is scope. `gcloud` had the mirror-image problem — its module is always-on
and reads `~/.config/gcloud`, so it advertised an identity everywhere, even
before the CLI was installed.

Fix: make cloud context a property of the directory. direnv sets it on entry and
restores the previous environment on exit.

## Helpers

Defined in `.config/direnv/direnvrc`, which direnv sources before every `.envrc`.

### `use aws <profile> [region]`

Exports `AWS_PROFILE`, optionally `AWS_REGION` / `AWS_DEFAULT_REGION`, and unsets
`CLOUDSDK_ACTIVE_CONFIG_NAME`, `CLOUDSDK_CORE_PROJECT`, `GOOGLE_CLOUD_PROJECT`.

```sh
# .envrc
use aws kodehort eu-west-2
```

### `use gcloud <configuration> [project] [service-account]`

Exports `CLOUDSDK_ACTIVE_CONFIG_NAME`, optionally `CLOUDSDK_CORE_PROJECT` /
`GOOGLE_CLOUD_PROJECT` and `CLOUDSDK_AUTH_IMPERSONATE_SERVICE_ACCOUNT`, and
unsets `AWS_PROFILE`, `AWS_REGION`, `AWS_DEFAULT_REGION`, `AWS_ACCESS_KEY_ID`,
`AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`.

```sh
# .envrc
use gcloud default genie-goals-analytics
```

`<configuration>` is a name from `gcloud config configurations list`, backed by
`~/.config/gcloud/configurations/config_<configuration>`. Both the gcloud CLI and
starship read `CLOUDSDK_ACTIVE_CONFIG_NAME`, so the prompt and the CLI agree and
nothing has to mutate global state with `gcloud config set`. `[project]`
overrides the project without touching the stored configuration — handy when
several projects share one login.

Run `direnv allow` after creating or editing an `.envrc`.

## Service account impersonation

Granted has no gcloud equivalent — the OSS CLI is AWS-only, `granted gcp` does
not exist in 0.38.0, and the GCP proposal in
[discussion #538](https://github.com/common-fate/granted/discussions/538) never
shipped. GCP access in Common Fate is a commercial platform feature needing a
deployment in your AWS account and Workload Identity Federation.

The nearest native equivalent to `assume <profile>` is impersonation, passed as
the third argument:

```sh
# .envrc
use gcloud default genie-goals-analytics deploy@genie-goals-analytics.iam.gserviceaccount.com
```

That sets `CLOUDSDK_AUTH_IMPERSONATE_SERVICE_ACCOUNT`, which is the environment
form of the `auth/impersonate_service_account` property. Check what is active
with `gcloud config get auth/impersonate_service_account`.

Constraints worth knowing:

- Your logged-in user needs `roles/iam.serviceAccountTokenCreator` on the target
  account. Without it, calls fail at request time, not on entering the directory.
- The argument must be a `…@….iam.gserviceaccount.com` address. Anything else
  fails the `.envrc` load rather than silently exporting a typo.
- Omitting the argument actively unsets the variable, so impersonation never
  leaks in from the surrounding shell. `use aws` clears it too.
- **Scope: gcloud, `gsutil` and `bq` only.** Application code using Application
  Default Credentials ignores it. For those, impersonate at the library level, or
  set the tool's own variable in the same `.envrc` — Terraform's Google provider
  reads `GOOGLE_IMPERSONATE_SERVICE_ACCOUNT`, kept separate here so the helper
  does not silently reconfigure other tools.

## Adding to a project that already has an `.envrc`

Put the `use` line first, above any `set -a` block, and delete variables the
helper now sets:

```sh
use gcloud default genie-goals-ads-mcp

set -a
PROJECT_ID=genie-goals-ads-mcp
REGION=europe-west2
CLOUDSDK_RUN_REGION=europe-west2
```

`CLOUDSDK_CORE_PROJECT` was dropped from the `set -a` block because
`use gcloud … genie-goals-ads-mcp` already exports it. Leaving a duplicate is
harmless but means two places to edit.

## Resulting prompt

With `assume kodehort` active in the shell:

| Directory | `aws` segment | `gcloud` segment |
| --------- | ------------- | ---------------- |
| a `use gcloud` project | hidden | the project's account |
| a `use aws` project | the profile | hidden |
| anywhere else | the assumed profile | hidden |

The last row is deliberate. Outside a scoped project the prompt still reports
whatever the shell holds, because that is the truth about your session.

## Prompt configuration

In `starship/.config/starship.toml`:

```toml
[gcloud]
detect_env_vars = [
  "CLOUDSDK_ACTIVE_CONFIG_NAME",
  "CLOUDSDK_CORE_PROJECT",
  "GOOGLE_CLOUD_PROJECT",
]
```

`detect_env_vars` gates the always-on `gcloud` module so it renders only where an
`.envrc` opts in. The `aws` module has no equivalent option — starship rejects it
with `Error in 'Aws' at 'detect_env_vars': Unknown key` — which is why scoping
`AWS_PROFILE` itself is the mechanism rather than a prompt-side filter.

Rejected alternative: a `when`-gated `[custom.aws]` module. It would land at
`$custom`'s position in the format string rather than `$aws`'s, moving the
segment, and would fork another subprocess on every render.

## Escape hatches

| Situation | Command |
| --------- | ------- |
| AWS profile stuck in this shell | `unassume` (`. assume --unset`) |
| Need AWS inside a `use gcloud` project | `assume <profile>` — wins until direnv reloads |
| Check active impersonation | `gcloud config get auth/impersonate_service_account` |
| Reload after editing `.envrc` | `direnv allow` |
| Check what a directory actually sets | `direnv exec <dir> env \| rg 'AWS_\|CLOUDSDK_\|GOOGLE_'` |

`assume` inside a scoped project holds only until direnv next reloads: `cd` out
and back, or `touch .envrc`, and the `.envrc`'s unsets apply again.

## Shellcheck

`.config/direnv/direnvrc` opens with `# shellcheck shell=bash` because the file
has no extension or shebang, and it is listed under `additional_files` in
`.github/workflows/test.yml` so CI scans it.

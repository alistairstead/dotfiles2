#!/usr/bin/env bun
import { z } from "zod";

const ArgsSchema = z.object({
  repo: z.string().optional(),
  prNumber: z.number().optional(),
  noBots: z.boolean().default(false),
  unresolvedOnly: z.boolean().default(false),
});

type Args = z.infer<typeof ArgsSchema>;

interface Comment {
  thread_id?: string;
  user: string;
  body: string;
  diff_hunk: string;
  line: number | null;
  start_line: number | null;
}

// CI/automation bots to filter when --no-bots is used
// Excludes Claude (github app) to preserve AI review comments
const CI_BOTS = ["github-actions", "dependabot", "renovate", "copilot"];

const GRAPHQL_QUERY = `
query($owner: String!, $name: String!, $pr: Int!, $cursor: String) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $pr) {
      reviewThreads(first: 100, after: $cursor) {
        pageInfo {
          hasNextPage
          endCursor
        }
        nodes {
          id
          isResolved
          comments(first: 1) {
            nodes {
              author { login, __typename }
              body
              diffHunk
              line
              startLine
            }
          }
        }
      }
    }
  }
}`;

async function exec(cmd: string[]): Promise<{ stdout: string; exitCode: number }> {
  const proc = Bun.spawn(cmd, { stdout: "pipe", stderr: "pipe" });
  const stdout = await new Response(proc.stdout).text();
  const exitCode = await proc.exited;
  return { stdout: stdout.trim(), exitCode };
}

async function detectRepo(): Promise<string | null> {
  const { stdout, exitCode } = await exec([
    "gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner"
  ]);
  return exitCode === 0 ? stdout : null;
}

async function detectPrNumber(): Promise<number | null> {
  const { stdout, exitCode } = await exec([
    "gh", "pr", "view", "--json", "number", "-q", ".number"
  ]);
  return exitCode === 0 ? parseInt(stdout, 10) : null;
}

async function fetchUnresolvedComments(
  owner: string,
  name: string,
  prNumber: number,
  noBots: boolean
): Promise<Comment[]> {
  const allThreads: any[] = [];
  let cursor: string | null = null;
  let hasNext = true;

  while (hasNext) {
    const args = [
      "gh", "api", "graphql",
      "-f", `query=${GRAPHQL_QUERY}`,
      "-f", `owner=${owner}`,
      "-f", `name=${name}`,
      "-F", `pr=${prNumber}`,
    ];
    if (cursor) {
      args.push("-f", `cursor=${cursor}`);
    }

    const { stdout, exitCode } = await exec(args);
    if (exitCode !== 0) {
      console.error("GraphQL query failed");
      process.exit(1);
    }

    const data = JSON.parse(stdout);
    const threads = data.data.repository.pullRequest.reviewThreads;
    allThreads.push(...threads.nodes);
    hasNext = threads.pageInfo.hasNextPage;
    cursor = threads.pageInfo.endCursor;
  }

  return allThreads
    .filter((t) => !t.isResolved)
    .filter((t) => {
      if (!noBots) return true;
      const login = t.comments.nodes[0]?.author?.login?.toLowerCase();
      return !CI_BOTS.includes(login ?? "");
    })
    .map((t) => {
      const c = t.comments.nodes[0];
      return {
        thread_id: t.id,
        user: c?.author?.login ?? "unknown",
        body: c?.body ?? "",
        diff_hunk: c?.diffHunk ?? "",
        line: c?.line ?? null,
        start_line: c?.startLine ?? null,
      };
    });
}

async function fetchAllComments(
  repo: string,
  prNumber: number,
  noBots: boolean
): Promise<Comment[]> {
  const { stdout, exitCode } = await exec([
    "gh", "api", `repos/${repo}/pulls/${prNumber}/comments`
  ]);
  if (exitCode !== 0) {
    console.error("REST API call failed");
    process.exit(1);
  }

  const comments: any[] = JSON.parse(stdout);
  return comments
    .filter((c) => {
      if (!noBots) return true;
      const login = c.user?.login?.toLowerCase();
      return !CI_BOTS.includes(login ?? "");
    })
    .map((c) => ({
      user: c.user?.login ?? "unknown",
      body: c.body ?? "",
      diff_hunk: c.diff_hunk ?? "",
      line: c.line ?? null,
      start_line: c.start_line ?? null,
    }));
}

function parseArgs(): Args {
  const args: Partial<Args> = {};
  const argv = process.argv.slice(2);

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--no-bots") {
      args.noBots = true;
    } else if (arg === "--unresolved") {
      args.unresolvedOnly = true;
    } else if (arg === "--repo" && argv[i + 1]) {
      args.repo = argv[++i];
    } else if (arg === "--pr" && argv[i + 1]) {
      args.prNumber = parseInt(argv[++i], 10);
    } else if (/^\d+$/.test(arg)) {
      args.prNumber = parseInt(arg, 10);
    } else if (arg.includes("/")) {
      args.repo = arg;
    }
  }

  return ArgsSchema.parse(args);
}

async function main() {
  const args = parseArgs();

  let repo = args.repo;
  if (!repo) {
    repo = await detectRepo();
    if (!repo) {
      console.error("Could not detect repository. Use --repo owner/name");
      process.exit(1);
    }
    console.error(`Detected repo: ${repo}`);
  }

  let prNumber = args.prNumber;
  if (!prNumber) {
    prNumber = await detectPrNumber();
    if (!prNumber) {
      console.error("Could not detect PR number. Use --pr NUMBER");
      process.exit(1);
    }
    console.error(`Detected PR #${prNumber}`);
  }

  let comments: Comment[];
  if (args.unresolvedOnly) {
    const [owner, name] = repo.split("/");
    comments = await fetchUnresolvedComments(owner, name, prNumber, args.noBots);
  } else {
    comments = await fetchAllComments(repo, prNumber, args.noBots);
  }

  console.log(JSON.stringify(comments, null, 2));
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});

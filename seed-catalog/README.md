# seed-catalog — Pier 36 Startup Seed

An **open, versioned** catalog of major AI figures, grouped into starter packs. Powers the in-app
**Startup Seed** page (one-tap follow + adopt interests) that solves the cold-start problem.

## Format
`figures.json`:
```jsonc
{
  "version": 1,
  "packs": [
    {
      "slug": "frontier-labs-llms",
      "title": "Frontier Labs & LLMs",
      "sort": 1,
      "figures": [
        {
          "name": "Andrej Karpathy",
          "bio": "LLMs, neural nets, education",
          "x_handle": "@karpathy",          // X activates in v2
          "blog_rss": "https://karpathy.github.io/feed.xml",
          "github_login": "karpathy",
          "arxiv_author": null,
          "youtube": null,
          "topics": ["LLMs", "Neural Nets", "Education"]
        }
      ]
    }
  ]
}
```

## Sync
A worker job loads this file into Supabase `seed_packs` / `seed_figures`. Because it's plain JSON in Git,
the catalog is **community-extensible** and updates without an app release.

> ⚠️ Verify handles, blog feeds, and GitHub logins before production — they change over time.
> Following a figure in MVP provisions their **blog + GitHub + arXiv** connectors; the **X handle is stored now
> and activates when the X connector ships in v2**.

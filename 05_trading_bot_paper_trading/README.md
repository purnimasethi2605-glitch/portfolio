# Paper trading agent

## About this project

A learning project. My goal was to understand how an automated AI agent is put together, using a paper trading account as the test case. Paper trading means practice trades with pretend money. No real money is involved.

The project follows a publicly shared guide for building a trading agent with Claude Code. The brokerage used in the guide was not available to me in Canada, so I set up a paper trading account with Moomoo Canada.

**Status:** learning project in progress.

## How the agent is designed

The agent has no memory between runs. Each time it starts, it reads its instructions and its own notes from files in the repository, does its work, and writes new notes back. Git keeps the full history.

* **Rulebook file (`CLAUDE.md`):** the instructions the agent reads first on every run
* **Routines:** scheduled prompts for each part of the trading day, such as research before the market opens, a midday check, an end of day summary and a weekly review
* **Scripts:** small wrapper scripts that are the only way the agent talks to outside services such as the broker, a research tool and a notification channel
* **Memory files:** the strategy rules, a log of every trade, a research log and a weekly review

## Risk rules in the strategy file

* Hold no more than 6 positions at a time
* Sell any position that falls 7 percent
* No options

## What I learned

* **How an agent keeps state.** Memory stored in files makes every decision visible and easy to audit.
* **Why wrappers matter.** Routing every outside call through one script means that when something breaks, there is one place to look.
* **Keeping secrets safe.** API keys live in a local `.env` file that is listed in `.gitignore` and never uploaded. Only a blank template is shared.
* **Reading API documentation.** Moving from one broker to another meant working out which parts of the design were general and which were specific to one service.

## Limits

This is a learning exercise in automation. It is not a tested trading strategy and it makes no claim about returns.

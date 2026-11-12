status: approved
ticket: tickets/0001-pista-longa/01-baseline-floresta-praia.md
reviewed_range: 007f8ebe79ba999f0dfc253bb1c40e1547ad14a9..248e61db2bfd05094a2937d4ae9e86b72bfbf96a

All 7 acceptance criteria pass. Security (BRANCH, gitleaks): 0 findings. npm test 18/18, test:godot all pass.

Suggestions (routed as planner amendment to ticket 02):
- Fingerprint covers only the player's run: Rival-only changes (sleepy speed 2.2->2.21, miss 0.35->0.36, RIVAL_STEER_SPEED 1.6->1.61) pass silently. Add rival final progress to the fingerprint, re-recorded from unchanged code.
- Assert runs == EXPECTED.size() so removed combinations are noticed.

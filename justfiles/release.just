# Shared release recipes. Import from a repo's justfile:
#   import '~/justfiles/release.just'
# Repo must have a ./releaseable.yml describing its projects.

# Release a project defined in releaseable.yml.
#   just release gatekeeper                     minor bump (default)
#   just release gatekeeper --patch             patch bump
#   just release gatekeeper --major             major bump
#   just release gatekeeper --force-dirty       allow dirty tree
#   just release --list                         list projects
#   just release --help                         usage
release *ARGS:
    release-project {{ARGS}}

# Show recent git tags for a project: `just release-tags gatekeeper`.
release-tags PROJECT:
    @git tag -l '{{PROJECT}}/v*' --sort=-v:refname | head -20

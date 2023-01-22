# github action to create and push a tag using the REST API

Problem: If an action pushes code using the repository’s GITHUB_TOKEN, a new workflow will not run even when the repository contains a workflow configured to run when push events occur.

The easy and RIGHT solution is to replace the GITHUB_TOKEN with your own "personal access token".

Anyhow, this brought me to the question of "how to write an github action". This is an example github action creating and pushing a tag.

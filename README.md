# Bintray garbage collector ♻️

At [Automattic](https://automattic.com), we use Bintray as the repository for our Android artifacts.
To make testing and reviewing development builds of our libraries, we automatically publish a binary for every push to remote.

To avoid having the repository size swell and to avoid wasting energy in storage of binaries that we no longer need, we periodically delete all the arfifacts from merged branches.

To do so, we use a CircleCI scheduled build and the Bintray CLI.

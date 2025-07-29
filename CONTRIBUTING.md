# Contributing to Mifos Gazelle
 Thank you for your interest in contributing to the Mifos Gazelle repository! Your contributions are important and will help to improve the project for everyone. Before you begin, please consider the guidelines below.

## Branches

* Master - contains released versions of the Mifos Gazelle product
* Dev - Where all contributions should be raised as PRs
* ... - Individual branches used by contributors for pre-staging or testing

Please always contribute to Dev. We then compile accepted PRs from Dev into releases within the community and publish these every 3 months.

## Getting Started

- View the [README](README.MD) to get your development environment up and running.
- Sign the [Contribution License Agreement](https://mifos.org/about-us/financial-legal/mifos-contributor-agreement/).
- Always follow the [code of conduct](https://mifos.org/resources/community/code-of-conduct/) - this is important to us. We are proud to be open, tolerant and providing a positive environment.
- Introduce yourself or ask a question on the [#mifos-gazelle-dev channel on Slack](https://mifos.slack.com/archives/C059L7BQMMH).
- Find a [Jira](https://mifosforge.jira.com/jira/software/c/projects/GAZ/issues?jql=project%20%3D%20%22GAZ%22%20ORDER%20BY%20created%20DESC) ticket to work on and start smashing!
- Make sure you have [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) installed on your machine.
- Fork the repository and clone it locally.

git clone --branch dev https://github.com/openMF/mifos-gazelle.git


- Create a new branch for your contributions
git checkout -b feature-branch-name


## Making Changes

- Before making changes, ensure that you're working on the latest version of the `dev` branch

git pull origin dev


## Committing Changes

- Stage your changes:

git add file-name(s)

- Commit your changes with a descriptive message:

git commit -m "Add feature"

- Push your changes to your forked repository:

git push origin feature-branch-name


## Submitting a Pull Request

- Follow the steps outlined in [GitHub's documentation](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request)

## Code Review

- After submitting your PR, our team will review your changes.
- Address any feedback or requested changes promptly.
- Once approved, your PR will be merged into the `dev` branch.
- Every 3 months we will release from the 'dev' branch to the 'master' branch

## Finding a Task

- Check out the issues [here](https://github.com/openMF/mifos-gazelle/issues)
- Join Mifos Slack
- Subscribe to the #mifos-gazelle slack channel (used for support on release versions)
- Request to join the Mifos-gazelle-dev slack channel
- Have a look at the README.md and our other documentation in /docs/ Can it be improved? Do you see any typos? You may initiate a PR.

## Reporting Issues

If you find any bugs or have recommendations for improvements, please feel free to [open an issue](https://github.com/openMF/mifos-gazelle/issues) with a detailed explanation of changes.

## Contact

- For further assistance or questions regarding contributions, feel free to join our Slack channel [here](https://mifos.slack.com/ssb/redirect)

Thank you again for your interest in [Mifos Gazelle](https://github.com/openMF/mifos-gazelle)! We look forward to your contributions.

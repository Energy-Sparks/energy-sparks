## Git workflow ##

- Pull requests must contain a succint, clear summary of what the user need is driving this feature change.
- Write clear commit messages
- Link to the issue you're working on or fixing
- Make a feature branch
- Pull requests are automatically integration tested, where applicable using [Travis CI](https://travis-ci.org/), which will report back on whether the tests still pass on your branch

## Code ##

- Must be readable with meaningful naming, eg no short hand single character variable names
- Rubocop is used for style checking, with various customisations [rubocop.yml](https://github.com/BathHacked/.rubocop.yml)

## Testing ##

Write tests.

Demo

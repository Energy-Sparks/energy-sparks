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

## Internationalisation

The application is translated into Welsh.  This is done via Transifex.  They store the master copy of the Welsh
translation which is used to update the files in config/locales/cy (so changes there will be lost).

The workflow is

- update English files in config/locales
- `rake i18n:copy_analytics_yaml` - what does this copy from? "currently installed"
- `rake i18n:generate_tx_config`
- `tx push`
- wait
- `tx pull --mode onlyreviewed --all`

Content in the database is also translated .... (this is handled separately?)



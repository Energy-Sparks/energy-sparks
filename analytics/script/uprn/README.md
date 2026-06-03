# Scanning for SMART meters using UPRNs

The n3rgy API provides a method for looking up information about smart metering
devices installed at an address using the UPRN.

This directory has some scripts for using that API to scan lists of addresses to
determine if a smart meter is installed. The intention is to identify schools
which have smart meters, so that we can either approach them to join EnergySparks
or, for existing users, switch to using an alternate method of loading their
energy data.

## Running the scripts

Run using bundler to ensure dependencies are loaded:

```
bundle exec ruby read-inventory-uprn.rb
```

## Read Inventory

```
Usage: read-inventory-uprn.rb [options]
    -v, --[no-]verbose               Run verbosely
    -u, --uprn UPRN                  Specify uprn
```

Performs a "read inventory" call for a single UPRN which is specified using the
`-u|--uprn` parameter.

Outputs the number of devices found, and some basic information about them.

If the `--verbose` option is specified then the script produces some extra debug
output, including the full JSON response from the API call.

## Scan Inventories

```
Usage: scan-inventories.rb [options]
    -v, --[no-]verbose               Run verbosely
    -f, --file FILE                  CSV file to parse
    -n, --no-header                  Indicate CSV has no header. UPRNs must be in first column
    -o, --output REPORT              Name of file to generate. Default: scan-inventory.csv
    -r, --retries RETRIES            Maximum number of retries to fetch inventory. Default: 5
    -i, --interval INTERVAL          Retry interval in seconds. Default: 15
    -e, --extract FIELDS             Fields to extract from input CSV and add to output. Comma-separated list of field names or indexes
    -h, --help                       Print options
```

Reads a CSV file containing a list of UPRNs and performs "read inventory" calls for
every row. It outputs a second CSV file that contains information about the devices found.

### Input format

The input CSV is expected to have a header row. The script will look for a column called "UPRN" and
use that as the parameter to the API call.

If the CSV doesn't have a header row then add the `--no-header` option. In this case the UPRN value is
assumed to be in the first column.

### Retrieving inventory responses

Retrieving the response for an inventory call requires checking an S3 URL for a JSON document. The document
is populated asynchronously, and so the script might encounter an HTTP 403 error until n3rgy have produced
a response.

The script retries a specific number of times, with an interval before giving up. These can be
adjusted using the `--retries` and `--interval` parameters. The default is to try 5 times with a 15 second interval.

### Output format

The output CSV is called `scan-inventory.csv`. An alternate file name and path can be given using the `--output` parameter.

The generated CSV will consist of the following columns:

```
"UPRN", "ID", "TYPE", "COMMISSIONED", "SMETS_CHTS_VERSION", "GBCS_VERSION"
```

* `UPRN` - as read from the input document
* `ID` - device id
* `TYPE`- device type, e.g. CHF, EMSE, etc
* `COMMISSIONED` - date that the device was commissioned. Might be null.
* `SMETS_CHTS_VERSION` - version of SMETS or CHTS to which the device conforms
* `GBCS_VERSION` - version of Great Britain Companion Specification the device supports

One row is produced for each device at the specified UPRN.

The output CSV can be enriched with additional columns from the input CSV. This can provide a bit more context
about which school has been matched.

Specify the columns to be copied to the output using the ``--extract`` parameter, e.g.:

```
bundle exec ruby scan-inventories -f input.csv -e "URN,EstablishmentName"
```

This will add the `URN` and `EstablishmentName` columns from the input to the output.

The script builds the CSV by adding the `UPRN` as the first column, then any extract fields, before finally adding
the information about each device.

If the input CSV doesn't have a header then specify index values (starting from 0) rather than column names.
The column headers will then be called `Field_0`, etc to match.

## Data preparation

Lists of schools with UPRNs can be found in various ways:

### Official lists of schools in England and Wales

* The Get Information About School (GIAS) service provides complete [downloads](https://www.get-information-schools.service.gov.uk/Downloads) of their database. Downloading the "Establishment Fields" CSV to get a large CSV that has a UPRN column. You will need to unpack the zip file they provide.
* The same service allows the results of a search to be downloaded as a CSV. Add the UPRN and other columns to create a working dataset. You will need to unpack the zip file they provide.

### Offical lists of schools in Scotland

Address data for Scottish school [can be found here](https://www.gov.scot/publications/school-contact-details/).

This will need to be manually reformatted as the spreadsheet is not suitable for processing as it stands:

* Delete all worksheets, except "Open schools"
* Delete the first few redundant rows
* Clear all formatting and remove filters
* Rename "Unique Property Reference Number (UPRN)" as "UPRN"
* Save as CSV

Note: this list doesn't include Independent schools, but [the public data doesn't contain UPRNs](https://www.gov.scot/publications/independent-schools-in-scotland-register/)

### Energy Sparks schools

EnergySparks doesn't currently hold the UPRNs of its schools. But after extracting a CSV of the current list of
schools, this list of registered can be merged with the Edubase download to add in the UPRNs, as well as other
fields.

This can be done from the command-line using `csvjoin`, e.g:

```
csvjoin es-schools.csv edubasealldata20211124-saved.csv -e utf-8 -c URN >joined.csv
```

The GIAS service downloads are not UTF-8 encoded, you will need to fix this before using `csvjoin`.
Simply opening in OpenOffice/LibreOffice and resaving as UTF-8 worked fine.

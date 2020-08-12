# Signspace connector tests

## System requirements

- Python 3.6.x
- [Poetry](https://python-poetry.org/docs/)

## Installation

Install RobotFramework and dependencies:

    poetry install


## Test results and running the tests

Check submit-connector-test-results for the performed tests results.

Also to run these tests authentication has to be disabled in app/routes/translator/v1/fetch/index.js by replacing line 16 with the following:

```
router.post('', ctrl.fetch);
```

Run connector locally from Dockerfile or with:

    npm start
... don't forget to pass SignSpace credentails with $CONFIGS env variable.

Navigate to /robottests directory and start test suite:

    poetry run python -m robot -A robotargs.txt connector_tests.robot

Results can be found in `result` folder.

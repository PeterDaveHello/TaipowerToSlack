# TaipowerToSlack

This script will help fetching the "Power Information of Today" from Taipower, to your Slack channel.

Taipower's "Power Information of Today" page:

- English: <https://www.taipower.com.tw/en/page.aspx?mid=4484>
- Chinese: <https://www.taipower.com.tw/tc/page.aspx?mid=206&cid=402&cchk=8c59a5ca-9174-4d2e-93e4-0454b906018d>

Please note that this is just a quite demo of using shell script, the code is ugly, and some magic is hard-coded.

## Screenshot

Slack Screenshot:

![SlackScreenshot](SlackScreenshot.png)

Terminal Screenshot:

![TerminalScreenshot](TerminalScreenshot.png)

## Usage

### Prepare your Slack Incoming Webhook URL

See [Slack's Documentation](https://api.slack.com/messaging/webhooks) for the details.

### Clone this project, or download the run.sh script

```sh
git clone https://github.com/PeterDaveHello/TaipowerToSlack
```

```sh
curl https://github.com/PeterDaveHello/TaipowerToSlack/raw/master/run.sh -o /path/to/TaipowerToSlack/run.sh
```

### Directly run the script, or run it using cron

Go to the directory of the script.

Set `SLACK_HOOK` variable in the shell script, or passing it when running the script:

```sh
SLACK_HOOK=https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX ./run.sh
```

The result should be displayed on your Slack channel like the screenshot.

### Only post to Slack when the status changed

Set the variable `STATELESS` to `false` and `ONLY_POST_ON_STATUS_CHANGE` to `true` in `run.sh` as below:

```sh
STATELESS="false"
ONLY_POST_ON_STATUS_CHANGE="true"
```

Then the script will use file `~/.taipower.status` to store the status, and only post the message to Slack when the status was changed.

## Dependencies

- `jq`, to parse the data
- `curl`, to fetch the data
- `bash`, to run the script
- `mktemp`, to create the temp file
- `bc`, to calculate the percentage from data

## License

This project is released under the [WTFPL v2 license](https://choosealicense.com/licenses/wtfpl/).

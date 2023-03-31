# TaipowerToSlack

TaipowerToSlack is a tool that fetches the "Power Information of Today" from Taipower and sends the data to a designated Slack channel, allowing users to easily monitor Taiwan's power supply status.

Taipower's "Power Information of Today" page:
- English: <https://www.taipower.com.tw/en/page.aspx?mid=4484>
- Chinese: <https://www.taipower.com.tw/tc/page.aspx?mid=206&cid=402&cchk=8c59a5ca-9174-4d2e-93e4-0454b906018d>

Please note that this is primarily a shell script demo, with code that might be less elegant and some hard-coded values.

## Screenshots

Slack Screenshot:

![SlackScreenshot](SlackScreenshot.png)

Terminal Screenshot:

![TerminalScreenshot](TerminalScreenshot.png)

## Setup and Usage

### 1. Obtain your Slack Incoming Webhook URL

Refer to [Slack's Documentation](https://api.slack.com/messaging/webhooks) for details on how to obtain an Incoming Webhook URL for your Slack channel.

### 2. Clone this repository or download the script

Clone the repository:

```sh
git clone https://github.com/PeterDaveHello/TaipowerToSlack
```

Or, download the run.sh script directly, and make the run.sh script executable:

```sh
curl https://github.com/PeterDaveHello/TaipowerToSlack/raw/master/run.sh -o /path/to/TaipowerToSlack/run.sh
chmod +x /path/to/TaipowerToSlack/run.sh
```

### 3. Configure and execute the script

Navigate to the directory containing the `run.sh` script.

Set the `SLACK_HOOK` variable in the shell script, or pass it when running the script:

```sh
SLACK_HOOK=https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX ./run.sh
```

The result should be displayed on your Slack channel as shown in the screenshot.

### 4. Optional: Post to Slack only when the status changes

To enable this option, set the `STATELESS` variable to `false`, and the `ONLY_POST_ON_STATUS_CHANGE` variable to `true` in `run.sh`:

```sh
STATELESS="false"
ONLY_POST_ON_STATUS_CHANGE="true"
```

With this configuration, the script will use the file `~/.taipower.status` to store the status and only post a message to Slack when the status changes.

## Dependencies

- `jq`: for parsing JSON data
- `curl`: for fetching JSON data from the Taipower API
- `bash`: for running the shell script
- `mktemp`: for creating temporary files
- `bc`: for calculating percentages from data

If any of these tools are missing, you can usually install them using your system's package manager (e.g., `apt`, `yum`, or `pacman`).

## License

This project is released under the [WTFPL v2 license](https://choosealicense.com/licenses/wtfpl/).

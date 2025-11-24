# shellcheck disable=SC2155
declare aws_region="$(get-aws-region)"
# shellcheck disable=SC2155
declare aws_profile="$(get-aws-profile)"
# shellcheck disable=SC2154
declare service="${args[--service]}"
declare base_aws_url="https://console.aws.amazon.com"

validate-or-refresh-aws-auth

if ! [[ -f /usr/local/bin/aws_console ]]; then
cat <<EOF >> aws_console
#!/usr/bin/env python3

import sys
import json
import webbrowser
import urllib.parse
import os
import argparse
from typing import Optional
import time
import pyautogui

import requests
import boto3


def get_logout_url(region: Optional[str] = None):
    urllib.parse.quote_plus(
        "https://aws.amazon.com/premiumsupport/knowledge-center/sign-out-account/?from_aws_sso_util_logout"
    )
    if not region or region == "us-east-1":
        return "https://signin.aws.amazon.com/oauth?Action=logout&redirect_uri="

    if region == "us-gov-east-1":
        return "https://us-gov-east-1.signin.amazonaws-us-gov.com/oauth?Action=logout"

    if region == "us-gov-west-1":
        return "https://signin.amazonaws-us-gov.com/oauth?Action=logout"

    return f"https://{region}.signin.aws.amazon.com/oauth?Action=logout&redirect_uri="


def get_federation_endpoint(region: Optional[str] = None):
    if not region or region == "us-east-1":
        return "https://signin.aws.amazon.com/federation"

    if region == "us-gov-east-1":
        return "https://us-gov-east-1.signin.amazonaws-us-gov.com/federation"

    if region == "us-gov-west-1":
        return "https://signin.amazonaws-us-gov.com/federation"

    return f"https://{region}.signin.aws.amazon.com/federation"


def get_destination_base_url(region: Optional[str] = None):
    if region and region.startswith("us-gov-"):
        return "https://console.amazonaws-us-gov.com"
    if region:
        return f"https://{region}.console.aws.amazon.com/"

    return "https://console.aws.amazon.com/"


def get_destination(
    path: Optional[str] = None,
    region: Optional[str] = None,
    override_region_in_destination: bool = False,
):
    base = get_destination_base_url(region=region)

    if path:
        stripped_path_parts = urllib.parse.urlsplit(path)[2:]
        path = urllib.parse.urlunsplit(("", "") + stripped_path_parts)
        url = urllib.parse.urljoin(base, path)
    else:
        url = base

    if not region:
        return url

    parts = list(urllib.parse.urlsplit(url))
    query_params = urllib.parse.parse_qsl(parts[3])
    if override_region_in_destination:
        query_params = [(k, v) for k, v in query_params if k != "region"]
        query_params.append(("region", region))
    elif not any(k == "region" for k, _ in query_params):
        query_params.append(("region", region))
    query_str = urllib.parse.urlencode(query_params)
    parts[3] = query_str

    url = urllib.parse.urlunsplit(parts)

    return url


def DurationType(value):
    value = int(value)
    if 15 < value < 720:
        raise ValueError("Duration must be between 15 and 720 minutes (inclusive)")
    return value


def main():
    parser = argparse.ArgumentParser(description="Launch the AWS console")

    parser.add_argument("--profile", metavar="PROFILE_NAME", help="A config profile to use")
    parser.add_argument("--region", metavar="REGION", help="The AWS region")
    parser.add_argument(
        "--destination",
        dest="destination_path",
        metavar="PATH",
        help="Console URL path to go to",
    )

    override_region_group = parser.add_mutually_exclusive_group()
    override_region_group.add_argument("--override-region-in-destination", action="store_true")
    override_region_group.add_argument(
        "--keep-region-in-destination",
        dest="override_region_in_destination",
        action="store_false",
    )

    open_group = parser.add_mutually_exclusive_group()
    open_group.add_argument(
        "--open",
        dest="open_url",
        action="store_true",
        default=None,
        help="Open the login URL in a browser (the default)",
    )
    open_group.add_argument(
        "--no-open",
        dest="open_url",
        action="store_false",
        help="Do not open the login URL",
    )

    print_group = parser.add_mutually_exclusive_group()
    print_group.add_argument(
        "--print",
        dest="print_url",
        action="store_true",
        default=None,
        help="Print the login URL",
    )
    print_group.add_argument(
        "--no-print",
        dest="print_url",
        action="store_false",
        help="Do not print the login URL",
    )

    parser.add_argument(
        "--duration",
        metavar="MINUTES",
        type=DurationType,
        help="The session duration in minutes",
    )

    logout_first_group = parser.add_mutually_exclusive_group()
    logout_first_group.add_argument(
        "--logout-first",
        "-l",
        action="store_true",
        default=True,
        help="Open a logout page first",
    )
    logout_first_group.add_argument(
        "--no-logout-first",
        dest="logout_first",
        action="store_false",
        help="Do not open a logout page first",
    )

    args = parser.parse_args()

    if args.open_url is None:
        args.open_url = True

    logout_first_from_env = False
    if args.logout_first is None:
        args.logout_first = os.environ.get("AWS_CONSOLE_LOGOUT_FIRST", "").lower() in [
            "true",
            "1",
        ]
        logout_first_from_env = True

    if args.logout_first and not args.open_url:
        if logout_first_from_env:
            logout_first_value = os.environ["AWS_CONSOLE_LOGOUT_FIRST"]
            raise parser.exit(f"AWS_CONSOLE_LOGOUT_FIRST={logout_first_value} requires --open")
        else:
            raise parser.exit("--logout-first requires --open")

    session = boto3.Session(profile_name=args.profile)

    if not args.region:
        args.region = session.region_name or os.environ.get("AWS_CONSOLE_DEFAULT_REGION")
    if not args.destination_path:
        args.destination_path = session._session.get_scoped_config().get("web_console_destination") or os.environ.get(
            "AWS_CONSOLE_DEFAULT_DESTINATION"
        )

    credentials = session.get_credentials()
    if not credentials:
        parser.exit("Could not find credentials")

    federation_endpoint = get_federation_endpoint(region=args.region)
    issuer = os.environ.get("AWS_CONSOLE_DEFAULT_ISSUER")
    destination = get_destination(
        path=args.destination_path,
        region=args.region,
        override_region_in_destination=args.override_region_in_destination,
    )

    launch_console(
        session=session,
        federation_endpoint=federation_endpoint,
        destination=destination,
        region=args.region,
        open_url=args.open_url,
        print_url=args.print_url,
        duration=args.duration,
        logout_first=args.logout_first,
        issuer=issuer,
    )


def launch_console(
    session: boto3.Session,
    federation_endpoint: str,
    destination: str,
    region: Optional[str] = None,
    open_url: Optional[bool] = None,
    print_url: Optional[bool] = None,
    duration: Optional[int] = None,
    logout_first: Optional[bool] = None,
    issuer: Optional[str] = None,
):
    if not issuer:
        issuer = "aws_console_launcher.py"

    read_only_credentials = session.get_credentials().get_frozen_credentials()

    session_data = {
        "sessionId": read_only_credentials.access_key,
        "sessionKey": read_only_credentials.secret_key,
        "sessionToken": read_only_credentials.token,
    }

    get_signin_token_payload = {
        "Action": "getSigninToken",
        "Session": json.dumps(session_data),
    }
    if duration is not None:
        get_signin_token_payload["SessionDuration"] = duration * 60

    response = requests.post(federation_endpoint, data=get_signin_token_payload)

    if response.status_code != 200:
        print("Could not get signin token", file=sys.stderr)
        print(response.status_code + "\n" + response.text, file=sys.stderr)
        sys.exit(2)

    token = response.json()["SigninToken"]

    get_login_url_params = {
        "Action": "login",
        "Issuer": issuer,
        "Destination": destination,
        "SigninToken": token,
    }

    request = requests.Request(method="GET", url=federation_endpoint, params=get_login_url_params)

    prepared_request = request.prepare()

    login_url = prepared_request.url

    if print_url:
        print(login_url)

    if open_url:
        if logout_first:
            logout_url = get_logout_url(region=region)
            webbrowser.open(logout_url, autoraise=False)
            time.sleep(1)
            os.system('wmctrl -a "Manage AWS Resources"')
            pyautogui.hotkey("ctrl", "w")

        webbrowser.open(login_url)


if __name__ == "__main__":
    main()
EOF

	chmod +x aws_console
	sudo mv aws_console /usr/local/bin/
fi

declare -A service_aliases=(
  [accessanalyzer]="access-analyzer"
  [alexaforbusiness]="a4b"
  [apigatewaymanagementapi]="apigateway"
  [apigatewayv2]="apigateway"
  [appconfig]="systems-manager/appconfig"
  [application-autoscaling]="awsautoscaling"
  [application-insights]="cloudwatch/home?#settings:AppInsightsSettings"
  [appstream]="appstream2"
  [autoscaling]="ec2/home#AutoScalingGroups:"
  [autoscaling-plans]="awsautoscaling/home#dashboard"
  [budgets]="billing/home#/budgets"
  [ce]="costmanagement/home#/cost-explorer"
  [chime]="chime-sdk"
  [clouddirectory]="directoryservicev2/home#!/cloud-directories"
  [cloudhsmv2]="cloudhsm"
  [cloudsearchdomain]="cloudsearch"
  [codeartifact]="codesuite/codeartifact"
  [codeguru-reviewer]="codeguru/reviewer"
  [codeguruprofiler]="codeguru/profiler"
  [cognito-identity]="iamv2/home#/identity_providers"
  [cognito-idp]="cognito/v2/idp"
  [cognito-sync]="appsync"
  [connectparticipant]="connect"
  [cur]="billing/home#/reports"
  [dax]="dynamodbv2/home#dax-clusters"
  [directconnect]="directconnect/v2/home"
  [dlm]="ec2/home#Lifecycle"
  [dms]="dms/v2"
  [ds]="directoryservicev2"
  [dynamodbstreams]="dynamodbv2"
  [ebs]="ec2/home#Volumes:"
  [ec2-instance-connect]="ec2/home#Instances:"
  [elastic-inference]="sagemaker"
  [elb]="ec2/home#LoadBalancers:"
  [elbv2]="ec2/home#LoadBalancers:"
  [es]="aos/home"
  [fms]="wafv2/fmsv2/home"
  [forecastquery]="forecast"
  [glacier]="glacier/home"
  [globalaccelerator]="globalaccelerattor/home"
  [identitystore]="singlesignon"
  [iot-data]="iot"
  [iot-jobs-data]="iot/home#/jobhub"
  [iot1click-devices]="iot/home#/thinghub"
  [iot1click-projects]="iot"
  [iotevents-data]="iotevents/home#/input"
  [iotsecuretunneling]="iot/home#/tunnelhub"
  [iotthingsgraph]="iot/home#/thinghub"
  [kafka]="msk"
  [kinesis-video-archived-media]="kinesisvideo/home"
  [kinesis-video-media]="kinesisvideo/home"
  [kinesis-video-signaling]="kinesisvideo/home#/signalingChannels"
  [kinesisanalyticsv2]="flink"
  [kinesisvideo]="kinesisvideo/home"
  [lex-models]="lexv2/home#bots"
  [lex-runtime]="lexv2/home#bots"
  [lightsail]="ls"
  [logs]="cloudwatch/home#logsV2:"
  [macie2]="macie"
  [marketplace-catalog]="marketplace/home#/search!mpSearch/search"
  [marketplace-entitlement]="marketplace"
  [marketplacecommerceanalytics]="marketplace/home#/vendor-insights"
  [mediapackage-vod]="mediapackagevod"
  [mediastore-data]="mediastore"
  [meteringmarketplace]="marketplace"
  [mgh]="migrationhub"
  [migrationhub-config]="migrationhub"
  [mq]="amazon-mq"
  [networkmanager]="networkmanager/home"
  [opsworkscm]="opsworks"
  [personalize]="personalize/home"
  [personalize-events]="personalize/home"
  [personalize-runtime]="personalize/home"
  [pi]="rds/home#performance-insights"
  [pinpoint]="pinpointv2"
  [pinpoint-email]="pinpoint/home#/email-account-settings/overview"
  [pinpoint-sms-voice]="pinpoint"
  [qldb-session]="qldb"
  [ram]="ram/home"
  [rds-data]="rds/home#query-editor:"
  [redshift-data]="redshiftv2/home#/query-editor:"
  [resourcegroupstaggingapi]="resource-groups"
  [route53domains]="route53/domains"
  [s3control]="s3"
  [sagemaker-a2i-runtime]="sagemaker/groundtruth#/a2i"
  [sagemaker-runtime]="sagemaker"
  [savingsplans]="costmanagement/home#/savings-plans/overview"
  [schemas]="events/home#/schemas"
  [sdb]="simpledb"
  [service-quotas]="servicequotas"
  [servicediscovery]="cloudmap"
  [shield]="wafv2/shieldv2"
  [sms]="mgn/home"
  [snowball]="snowfamily"
  [ssm]="systems-manager"
  [sso]="singlesignon"
  [sso-admin]="singlesignon"
  [sso-oidc]="singlesignon"
  [stepfunctions]="states"
  [sts]="iam"
  [swf]="swf/v2"
  [translate]="translate/home"
  [waf]="wafv2/homev2"
  [waf-regional]="wafv2/homev2"
  [wafv2]="wafv2/homev2"
  [workdocs]="zocalo"
  [workmailmessageflow]="workmail"
  [xray]="xray/home"
)

case "$service" in
    "pricing")
        firefox "https://calculator.aws" > /dev/null 2>&1
        exit
        ;;
    "mturk")
        firefox "https://mturk.com" > /dev/null 2>&1
        exit
        ;;
    "quicksight")
        firefox "quicksight.aws.amazon.com" > /dev/null 2>&1
        exit
        ;;
    *)
        if [[ -v service_aliases["$service"] ]]; then
            service_url="${base_aws_url}/${service_aliases[$service]}"
        else
            service_url="${base_aws_url}/${service}"
        fi
        ;;
esac

aws_console --profile "$aws_profile" --region "$aws_region" --destination "$service_url"

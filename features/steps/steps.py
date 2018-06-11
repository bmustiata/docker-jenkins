from germanium.static import *
from behave import use_step_matcher, given, when, then, step
import os

use_step_matcher("re")


@given(u'I open the local jenkins')
def open_local_jenkins(context):
    open_browser("ff")


@when(u'I wait for the jenkins to load')
def wait_jenkins_to_load(context):
    if "JENKINS_URL" not in os.environ:
        raise Exception("Missing JENKINS_URL environment variable.")

    jenkins_location = os.environ["JENKINS_URL"]

    go_to(jenkins_location)


@then(u'I get the jenkins main page')
def check_jenkins_to_main_page(context):
    wait(Link("New Item"), timeout=60)

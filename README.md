This is an example of testing a plugin in the __Moodle Workplace Multi-tenancy testing infrastructure__.

It has several Travis jobs, two of them run tests on [Moodle LMS](https://github.com/moodle/moodle) and two on 
[Moodle Workplace testing repository](https://github.com/moodleworkplace/multitenancy)
(see [.travis.yml]()).

The [README](https://github.com/moodleworkplace/multitenancy/blob/master/admin/tool/tenant/README.md) file in 
the tool_tenant plugin explains how to modify the plugin code so it can run both with Moodle LMS and
Moodle Workplace supporting multi-tenancy.

Find the commit that is called "MOODLE WORKPLACE..."
[in the list of commits](https://github.com/moodleworkplace/multitenancy/commits/master) to see examples of modifications of:
- user selector
- manual enrolment method
- awarding and viewing awarded badges code

There are more core modifications in the actual Moodle Workplace and also much more functionality than in this
testing repository.

### About this plugin

This plugin (local_tenantexample) contains several PHPUnit and several Behat tests to demonstrate multi-tenancy features 
on the example of manual enrolment.

More tests and examples of the generators can be found in the
[tool_tenant](https://github.com/moodleworkplace/multitenancy/tree/master/admin/tool/tenant/tests) plugin

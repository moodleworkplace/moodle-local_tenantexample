<?php
// This file is part of Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <http://www.gnu.org/licenses/>.

/**
 * File containing tests for local_tenantexample plugin
 *
 * @package    local_tenantexample
 * @copyright  2020 Moodle Pty Ltd <support@moodle.com>
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

/**
 * Tests for the local_tenantexample
 *
 * @package    local_tenantexample
 * @copyright  2020 Moodle Pty Ltd <support@moodle.com>
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
class local_tenantexample_testcase extends advanced_testcase {
    /** @var stdClass */
    private $course = null;
    /** @var array */
    private $users = [];

    /**
     * Tests set up
     */
    protected function setUp() {
        global $CFG;
        require_once($CFG->dirroot . '/enrol/locallib.php');

        // Create the course and the teacher user who is enrolled as a teacher.
        $this->course = $this->getDataGenerator()->create_course();
        $this->users['teacher'] = $this->getDataGenerator()->create_user(['username' => 'teacher']);
        $this->getDataGenerator()->enrol_user($this->users['teacher']->id, $this->course->id, 'teacher');

        // Make sample users and not enroll to any course.
        $this->users['testapiuser1'] = $this->getDataGenerator()->create_user(['username' => 'testapiuser1']);
        $this->users['testapiuser2'] = $this->getDataGenerator()->create_user(['username' => 'testapiuser2']);
        $this->users['testapiuser3'] = $this->getDataGenerator()->create_user(['username' => 'testapiuser3']);
    }

    /**
     * Test get_potential_users without multitenancy plugin
     */
    public function test_get_potential_users() {
        global $DB, $PAGE;
        $this->resetAfterTest();

        // Without multitenancy the teacher can see all unenrolled users on the site as potential
        // users for the enrolment.
        $this->setUser($this->users['teacher']);

        $expectedusers = ['testapiuser1', 'testapiuser2', 'testapiuser3'];

        $enrol = $DB->get_record('enrol', array('courseid' => $this->course->id, 'enrol' => 'manual'));
        $manager = new course_enrolment_manager($PAGE, $this->course);
        $users = $manager->get_potential_users($enrol->id,
            'testapiuser',
            true,
            0,
            10,
            0,
            true);

        $this->assertEqualsCanonicalizing($expectedusers, array_column($users['users'], 'username'));
        $this->assertCount(count($expectedusers), $users['users']);
        $this->assertEquals(false, $users['moreusers']);
        $this->assertEquals(count($expectedusers), $users['totalusers']);
    }

    /**
     * Test get_potential_users with multitenancy plugin
     */
    public function test_get_potential_users_multitenancy() {
        global $DB, $PAGE;
        if (!core_component::get_component_directory('tool_tenant')) {
            $this->markTestSkipped('Multi-tenancy plugin not available');
        }
        $this->resetAfterTest();

        /** @var tool_tenant_generator $tenantgenerator */
        $tenantgenerator = $this->getDataGenerator()->get_plugin_generator('tool_tenant');
        $tenant = $tenantgenerator->create_tenant();

        // Allocate users testapiuser1, testapiuser2 and teacher to the same tenant.
        $tenantgenerator->allocate_user($this->users['testapiuser1']->id, $tenant->id);
        $tenantgenerator->allocate_user($this->users['testapiuser2']->id, $tenant->id);
        $tenantgenerator->allocate_user($this->users['teacher']->id, $tenant->id);

        // Set the current user to the 'teacher' and repeat the test. Only users from the same tenant will be returned.
        $this->setUser($this->users['teacher']);

        $expectedusers = ['testapiuser1', 'testapiuser2'];

        $enrol = $DB->get_record('enrol', array('courseid' => $this->course->id, 'enrol' => 'manual'));
        $manager = new course_enrolment_manager($PAGE, $this->course);
        $users = $manager->get_potential_users($enrol->id,
            'testapiuser',
            true,
            0,
            10,
            0,
            true);

        $this->assertEqualsCanonicalizing($expectedusers, array_column($users['users'], 'username'));
        $this->assertCount(count($expectedusers), $users['users']);
        $this->assertEquals(false, $users['moreusers']);
        $this->assertEquals(count($expectedusers), $users['totalusers']);
    }
}
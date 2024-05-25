# NOTE: We would like to simply run all the unittests for opmcommon and opmsimulators
#     using "python -m unittest discover", but the opmsimulators tests needs to be run
#     separately due to the mpi init and finalize issues. This script is a workaround
#     to run only the opmcommon tests using python -m unittest discover.
#     Since the opmcommon python tests uses relative imports, we need to add the current
#     directory 'tests' to the sys.path. This script does that and runs the tests.
#
# NOTE: This script assumes that it is run from the 'tests' directory.
#
import os
import sys
import unittest

# Add the 'tests' directory to the sys.path
sys.path.append(os.getcwd())

def load_tests(loader, tests, pattern):
    suite = unittest.TestSuite()
    for all_test_suite in unittest.defaultTestLoader.discover('.', pattern=pattern):
        for test_suite in all_test_suite:
            if isinstance(test_suite, unittest.loader._FailedTest):
                #print(f"Failed test suite: {test_suite}, Reason: {test_suite._exception}")
                pass
            else:
                for test in test_suite:
                    if isinstance(test, unittest.TestCase):
                        if test.id().startswith('opmcommon.'):
                            #print(f"Adding test: {test.id()}")
                            suite.addTest(test)
    return suite

if __name__ == '__main__':
    loader = unittest.TestLoader()
    tests = load_tests(loader, None, 'test*.py')
    runner = unittest.TextTestRunner()
    runner.run(tests)


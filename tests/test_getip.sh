#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Setup test environment
setup() {
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)/.."
    export PATH="$SCRIPT_DIR:$PATH"

    # Create mock commands directory
    MOCK_DIR="/tmp/mock_bin"
    mkdir -p "$MOCK_DIR"
    export PATH="$MOCK_DIR:$PATH"
}

# Create mock ip command
create_mock_ip() {
    cat >"$MOCK_DIR/ip" <<'EOL'
#!/bin/bash
case "$*" in
    *"link show"*"nonexistent"*)
        exit 1
        ;;
    *"link show eth0"*)
        echo "eth0: UP"
        exit 0
        ;;
    *"-4 a s eth0"*)
        echo "    inet 192.168.1.100/24 scope global eth0"
        ;;
    *"-6 a s eth0"*)
        echo "    inet6 2001:db8::1/64 scope global eth0"
        ;;
    *"link show"*)
        echo "eth0: UP"
        echo "wlan0: DOWN"
        ;;
    *)
        exit 1
        ;;
esac
EOL
    chmod +x "$MOCK_DIR/ip"
}

# Test helper functions
assert_success() {
    if [ $1 -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

assert_failure() {
    if [ $1 -ne 0 ]; then
        return 0
    else
        return 1
    fi
}

assert_contains() {
    if echo "$1" | grep -q "$2"; then
        return 0
    else
        return 1
    fi
}

run_test() {
    local test_name=$1
    local test_function=$2

    TESTS_RUN=$((TESTS_RUN + 1))
    echo -n "Running test: $test_name... "

    if $test_function; then
        echo -e "${GREEN}PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test cases


test_version_output() {
    create_mock_ip
    output=$("$SCRIPT_DIR/getip.sh" -v)
    assert_success $? && assert_contains "$output" "GetIP"
}

test_valid_interface_ipv4() {
    create_mock_ip
    output=$("$SCRIPT_DIR/getip.sh" -4 eth0)
    assert_success $? && assert_contains "$output" "eth0 IPv4"
}

test_valid_interface_ipv6() {
    create_mock_ip
    output=$("$SCRIPT_DIR/getip.sh" -6 eth0)
    assert_success $? && assert_contains "$output" "eth0 IPv6"
}

test_invalid_interface() {
    create_mock_ip
    output=$("$SCRIPT_DIR/getip.sh" nonexistent 2>&1)
    assert_failure $? && assert_contains "$output" "Invalid interface: nonexistent"
}

test_raw_output() {
    create_mock_ip
    output=$("$SCRIPT_DIR/getip.sh" --raw eth0)
    assert_success $? && [ "$output" = "192.168.1.100" ]
}

test_list_interfaces() {
    create_mock_ip
    output=$("$SCRIPT_DIR/getip.sh" -l)
    assert_success $? && assert_contains "$output" "Available Network Interfaces"
}

# Run tests
setup
run_test "Version Output" test_version_output
run_test "Valid Interface IPv4" test_valid_interface_ipv4
run_test "Valid Interface IPv6" test_valid_interface_ipv6
run_test "Invalid Interface" test_invalid_interface
run_test "Raw Output" test_raw_output
run_test "List Interfaces" test_list_interfaces

# Print summary
echo
echo "Test Summary:"
echo "-------------"
echo "Total tests: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

# Exit with failure if any tests failed
[ $TESTS_FAILED -eq 0 ] || exit 1

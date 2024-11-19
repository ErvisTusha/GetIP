#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    
    # Source script
    SCRIPT_DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
    PATH="$SCRIPT_DIR:$PATH"
    
    # Create mock commands directory
    MOCK_DIR="$BATS_TEST_TMPDIR/mock_bin"
    mkdir -p "$MOCK_DIR"
    PATH="$MOCK_DIR:$PATH"
}

# Mock command helpers
create_mock_ip() {
    cat > "$MOCK_DIR/ip" <<EOF
#!/bin/bash
if [[ \$* == *"link show eth0"* ]]; then
    echo "eth0: UP"
    exit 0
elif [[ \$* == *"-4 a s eth0"* ]]; then
    echo "    inet 192.168.1.100/24 scope global eth0"
elif [[ \$* == *"-6 a s eth0"* ]]; then
    echo "    inet6 2001:db8::1/64 scope global eth0"
elif [[ \$* == *"link show"* ]]; then
    echo "eth0: UP"
    echo "wlan0: DOWN"
else
    exit 1
fi
EOF
    chmod +x "$MOCK_DIR/ip"
}

create_mock_missing_ip() {
    rm -f "$MOCK_DIR/ip"
}

@test "Check missing dependencies" {
    create_mock_missing_ip
    run getip.sh
    assert_failure
    assert_output --partial "Error: ip command not found"
}

@test "Check version output" {
    create_mock_ip
    run getip.sh -v
    assert_success
    assert_output --partial "GetIP"
    assert_output --partial "Network Interface IP Tool"
}

@test "Check valid interface IPv4" {
    create_mock_ip
    run getip.sh -4 eth0
    assert_success
    assert_output --partial "eth0 IPv4"
}

@test "Check valid interface IPv6" {
    create_mock_ip
    run getip.sh -6 eth0
    assert_success
    assert_output --partial "eth0 IPv6"
}

@test "Check invalid interface" {
    create_mock_ip
    run getip.sh nonexistent
    assert_failure
    assert_output --partial "Invalid interface: nonexistent"
}

@test "Check raw output format" {
    create_mock_ip
    run getip.sh --raw eth0
    assert_success
    assert_line --index 0 "192.168.1.100"
}

@test "Check list interfaces" {
    create_mock_ip
    run getip.sh -l
    assert_success
    assert_output --partial "Available Network Interfaces"
}
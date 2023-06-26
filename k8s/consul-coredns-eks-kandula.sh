#!/usr/bin/env python3
import sys
import subprocess
import yaml

default_file = "coredns-configmap-template.yaml"
arg_place_holder = "<Consul ClusterIP IP>"


def replace_forward_ip(yaml_data, ip):
    corefile = yaml_data["data"]["Corefile"]
    corefile = corefile.replace(arg_place_holder, ip)
    yaml_data["data"]["Corefile"] = corefile
    return yaml_data


def apply_configmap(yaml_data):
    temp_file = "temp.yaml"
    with open(temp_file, "w") as file:
        yaml.dump(yaml_data, file)

    subprocess.run(["kubectl", "apply", "-f", temp_file], check=True)

    subprocess.run(["rm", temp_file], check=True)


if __name__ == "__main__":
    # ip = sys.stdin.read().strip()
    ip = sys.argv[1] if len(sys.argv) > 1 else ""
    if ip is None and len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Usage: python3 script.py <ip> <file> or stdin (as IP)")
        sys.exit(1)

    yaml_file = default_file
    if len(sys.argv) > 1:
        ip = sys.argv[1]
        if len(sys.argv) > 2:
            yaml_file = sys.argv[2]

    print(f"using IP {ip}")
    print(f"using file '{yaml_file}'")

    try:
        with open(yaml_file, "r") as file:
            yaml_data = yaml.safe_load(file)
    except FileNotFoundError as ex:
        print(f"No such file or directory: '{yaml_file}'")
        sys.exit(1)

    modified_yaml_data = replace_forward_ip(yaml_data, ip)
    apply_configmap(modified_yaml_data)
## How to build, install and use the snapshot-exclude-demo snap:

### Install snapcraft
```
sudo snap install snapcraft --classic
```
### Install lxd
```
sudo snap install lxd
```
### Install git
```
sudo apt update
sudo apt install -y git
```
### Install curl
```
sudo snap install curl
```
### Install jq
```
sudo snap install jq
```
### Clone repo
```
cd ~/
git clone https://github.com/ernestl/snapshot-exclude-dynamic-demo.git
```
### Build the snapshot-exclude-dynamic-demo snap in lxd container
```
cd ~/snapshot-exclude-dynamic-demo
snapcraft --use-lxd --debug
```
### Install the snap (note: this is a development mode snap)
```
sudo snap install snapshot-exclude-demo_0.1_amd64.snap --devmode --dangerous 
```
### Run the snap bash application to create $SNAP_USER_COMMON and $SNAP_USER_DATA and exit
```
snapshot-exclude-demo.bash
```
and exit
```
exit
```

### Create the system data for the test case as super user (required)
```
sudo snapshot-exclude-demo.create-system-data
```
This creates the following system data in /var/snap/snapshot-exclude-demo/:
```
├── common
│   ├── generic
│   │   └── file.dat
│   └── static-exclude.txt
├── current -> x1
└── x1
    ├── excl-1
    │   └── file.log
    ├── excl-2
    │   └── file.log
    ├── state-info
    │   └── state.dat
    └── static-exclude.txt
```
### Create the user data for the test case
```
snapshot-exclude-demo.create-user-data
```
This creates the following user data in ~/snap/snapshot-exclude-demo/:
```
├── common
│   ├── generic
│   │   └── file.dat
│   ├── static-exclude.txt
│   └── tmp
│       └── file.tmp
├── current -> x1
└── x1
    ├── large-files
    │   ├── large-file-not-used.bin
    │   ├── large-file-not-used.dat
    │   └── large-file-used.bin
    └── static-exclude.txt
```
### Take a dynamic snapshot
The dynamic snapshot mechanism is based on direct use of the REST API. The helper 
script `rest_api_call_test_dynamic_exclusions.sh` was created to simplify this for demonstration purposes.
```
sudo ./rest_api_call_test_dynamic_exclusions.sh
```
The script performs a REST API call and prints the snapshot set ID followed by the snapshot metadata that 
is requested with a second, different REST API call:
```
Calling REST API /v2/snaps to action snapshot with dynamic exclusion...
Snapshot set ID is: 523
Metadata for set ID 523 is:
{
  "type": "sync",
  "status-code": 200,
  "status": "OK",
  "result": [
    {
      "id": 523,
      "snapshots": [
        {
          "set": 523,
          "time": "2023-03-08T13:39:52.544831941+02:00",
          "snap": "snapshot-exclude-demo",
          "revision": "x1",
          "epoch": {
            "read": [
              0
            ],
            "write": [
              0
            ]
          },
          "summary": "",
          "version": "0.1",
          "sha3-384": {
            "archive.tgz": "2fd5744aec8650320f7ec5d41a9b2da30fa1189f66dedc9273249db1c685bee62b56e4f89d0032eab95502f39969dfb6",
            "user/ernest.tgz": "dff8f759f252834ac58c1b8618e9bb64f1d06d6320f562d6bca6958ca64cf2828d4871e912efdcfb95166ac6a6a88809",
            "user/root.tgz": "e404b2d3b628d46f0dae81559fc7b62dc3b67fec680fcb28c953e7f35fed8a98c08ace20bf2a2542907fc40cf8e44ef7"
          },
          "size": 594,
          "options": {
            "exclude": [
              "$SNAP_DATA/excl-*",
              "$SNAP_COMMON/.cache",
              "$SNAP_USER_COMMON/tmp",
              "$SNAP_USER_DATA/large-files/*-not-used.*"
            ]
          }
        }
      ]
    }
  ]
}
```
Only the dynamic snapshot exclusions are included in the snapshot options metadata.
Take note of the set ID.

### Restore the snapshot
```
snap restore <set ID>
```
This restores the system data that was not excluded from the snapshot in /var/snap/snapshot-exclude-demo/:
```
├── common
│   └── generic
│       └── file.dat
├── current -> x1
└── x1
    └── state-info
        └── state.dat
```
as well as the user data that was not excluded from the snapshot in ~/snap/snapshot-exclude-demo/:
```
├── common
│   └── generic
│       └── file.dat
├── current -> x1
└── x1
    └── large-files
        └── large-file-used.bin
```
The static exclusions defined in `snapshots.yaml` is always taken into account, but the exclusion are not included in the snapshot options metadata.
The dynamic exclusions are applied as requested per the "snapshot-options" definition for the REST API call, only for that call, and included in the snapshot options metadata.

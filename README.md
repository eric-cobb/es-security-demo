<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>
<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

Sometimes the Eden demos are down, parts of them are broken, or we just want more control over the enviroment than we can get through Eden. This is a small collection of binaries and scripts to trigger Elastic Security detection rules. It simulates an ssh login, privilege escalation, malicious binary activity (without the _actual_ malicious activity), and data exfiltration, all of which will be captured by Elastic Defend.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Prerequisites

_NOTE: skip this section unless you know you need to change the C code within the binaries; this is not necessary for normal use_

This repo contains everything you need for it to just _work_, including the binaries that will be used to trigger some alerts. That said, the C code for those binaries is also included in the event you want to compile them for yourself (e.g. you don't trust me, you need to run them on an architecture other than x86, etc). If you do want to compile them yourself, you'll need a compiler like GCC.
1. Install gcc compiler, if desired
   ```sh
   yum install gcc
   ```
   Then, from the base directory of the repo, compile the binaries
   ```sh
   gcc src/move_along.c -o bin/move_along
   gcc src/nothing_to_see_here.c -o bin/nothing_to_see_here
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running, just clone this repo into a directory on your local host
```sh
git clone https://github.com/eric-cobb/es-security-demo.git
```

The project is structured like so:
```sh
├── bin                       # Contains the binaries that will trigger alerts from shared memory; will not be use directly
│   ├── move_along                     
│   └── nothing_to_see_here
├── files   
│   ├── demo_progs.tar        # The tar file that contains binaries in bin/ that will trigger alerts in /dev/shm/
│   └── eicar_com.tar.gz      # Harmless eicar file that Defend will see as a malicious process
├── osquery                   # OSquery file(s) that can be used during alert investigation
│   └── osquery_find_deleted_processes
├── README.md
├── response                  # Files that can be executed from the Response Console to show response actions
│   └── response_file.sh
├── screenshots
│   ├── es-sec-demo_alerts_view.png
│   ├── es-sec-demo_attack_discovery.png
│   ├── es-sec-demo_building_blocks.png
│   ├── es-sec-demo_deleted_processes_running.png
│   ├── es-sec-demo_event_analyzer.png
│   ├── es-sec-demo_isolate_host.png
|   ├── es-sec-demo_overview.png
│   ├── es-sec-demo_release_host.png
│   └── es-sec-demo_remove_command.png
├── scripts             # The heart of the demo environment
│   ├── config.sh       # Contains variables used by these scripts
|   ├── demo_setup.sh   # The setup script that copies files over to the target host and gets the environment ready to run
│   ├── demo_start.sh   # Script (run from local machine) that kicks off all the "malicious" activity by calling exfill.sh
│   └── exfill.sh       # Does all the "malicious" dirty work
└── src                 # Source files for the binaries in case you want to modify them to your liking (just remember to re-compile)
    ├── move_along.c
    └── nothing_to_see_here.c
```
The whole demo process is depicted at a high level here:
![Project overview](screenshots/es-sec-demo_overview.png)

### Preliminary Setup
First, we need to set up some SSH keys for the Local Machine, TARGET_HOST, and EXFILL_TARGET. These are needed to allow the demo kick-off from the local machine to the TARGET_HOST, and exfill from the TARGET_HOST to the EXFILL_TARGET:

* Local machine - ssh key pair for the ssh to TARGET_HOST; copy the public key to TARGET_HOST user
* TARGET_HOST - ssh key pair (recommend passphrase-less key) for the scp "exfill" of data to the EXFILL_HOST; copy the public key to EXFILL_HOST user
* EXFILL_HOST - only public key from TARGET_HOST key pair needed here

_NOTE: The ssh user account on the TARGET_HOST needs password-less sudo privs to work properly_

Once the ssh users and keys are created and they're placed on the respective Local, TARGET, and EXFILL hosts, we can proceed.

1. All demo scripts source variables from `scripts/config.sh`. In the `scripts/config.sh` script, modify the following values to mirror your environment:
   ```sh
   TARGET_HOST=''          # The hostname or IP of the host to which this script will attempt to login and start triggering alerts
   TARGET_HOST_ROOTDIR=''  # Base directory from which all of these alert triggers will be run on the target host
   TARGET_HOST_SSH_USER='' # The user SSH account on the TARGET_HOST that the demo_start.sh script will use to ssh into the TARGET_HOST from the local machine
   EXFILL_TARGET=''        # Where the scp command will attempt to "exfill" the data; another cloud instance or other host
   EXFILL_SSH_USER=''      # The user SSH account on the EXFILL_TARGET
   EXFILL_SSH_KEY=''       # The user account SSH private key on the TARGET_HOST that will be used to scp the 'exfill' data to the EXFILL_TARGET
   LOCAL_SSH_KEY=''        # The local machine private key; used by the demo_setup.sh and demo_start.sh scripts on local machine to ssh into the TARGET_HOST
   FILE='/dev/shm/totally_not_exfill.tar.gz' # The file that will be "exfilled." Recommended to leave this as-is unless you _know_ you need to change it
   ```
2. Within Elastic Security, you'll need an Agent Policy assigned to an Agent running on the TARGET_HOST and EXFILL_HOST machines running the following integrations:

   * Defend
   * Auditd Manager
   * OSquery Manager
   * System
   * Threat Intelligence (optional)
   
   You'll also need the following Detection Rules enabled:
   
   * Endpoint Security (Elastic Defend)
   * Potential Data Exfiltration Through Curl
   * Linux Restricted Shell Breakout via Linux Binary(s)
   * Account or Group Discovery via Built-In Tools
   * Linux System Information Discovery
   * DLR PPC Indicator Match
   * Binary Executed from Shared Memory Directory
   * Sensitive Files Compression
   * Threat Intel URL Indicator Match (optional)

3. First let's set up the demo environment with `demo_setup.sh` before kicking off the detection triggers:
```sh
[user@host es-security-demo]$ sh demo_setup.sh
Enter passphrase for /Users/user/.ssh/id_ecdsa:
Copying files to xxx.xxx.xxx.xxx:/home/user/es-security-demo...Done
``` 
This copies the `bin/`, `files/`, `response/`, `scripts/`, and `src/` directories to the TARGET_HOST

4. Now we are ready to start causing havoc on the TARGET_HOST!

<!-- USAGE EXAMPLES -->
## Usage
### Modifying the C code (not required for normal demo operation)
_NOTE: The binaries (`bin/nothing_to_see_here` and `bin/move_along`) are written to run with default values and arguments, but those can be changed to fit your environment._ 

For usage examples, run:

   nothing_to_see_here
   ```sh
   [user@host bin]$ ./nothing_to_see_here -h
   Usage:
   ./nothing_to_see_here [program-to-run] [args...]
   ./nothing_to_see_here [flags-for-default]

   Behavior:
   • If the first argument starts with '-', arguments are passed to the default program:
         ./nothing_to_see_here -s 60 -c "/bin/echo hi"  -> runs /dev/shm/move_along with those flags
   • If the first argument does not start with '-', it is treated as the program to run:
         ./nothing_to_see_here /usr/bin/echo hello        -> runs /usr/bin/echo hello
   • If no arguments are given, runs the default program with no args.

   Options:
   -h, --help   Show this help (for the launcher)
   ```

   move_along
   ```sh
   [user@host bin]$ ./move_along -h
   usage: ./move_along [-s seconds] [-c "command"]

   Runs a shell command (default is a tar invocation) and then sleeps.

   Options:
   -s seconds   Sleep duration after the command (default: 10800)
   -c command   Shell command to execute (default:
                  "/usr/bin/tar czPf totally_not_exfill.tar.gz /etc/passwd")
   -h           Show this help and exit

   Examples:
   ./move_along                      # uses default tar command, then sleeps 3h
   ./move_along -s 300               # default command, sleep 5 min
   ./move_along -c "/usr/bin/echo hi"  # custom command, default sleep
   ```
### Normal Usage
Kick off the detection trigger activity. This will attempt to ssh into the TARGET_HOST, run some commands, and do some things that trigger alerts. On your local machine you'll see some short output while these actions are taking place, followed by a ping to the TARGET_HOST:
```sh
[user@host es-security-demo]$ sh demo_start.sh
Enter passphrase for /Users/user/.ssh/id_ecdsa:
Generating some random noise for the Event Analyzer view...Done
Triggering Account Discovery alerts...Done
Copying binaries over and executing...Done
Triggering Indicator Match Detection Rules...Done
Triggering Malware alert with EICAR file...Done
Triggering Linux system info discovery rule...Done
Copying /dev/shm/totally_not_exfill.tar.gz to xxx.xxx.xxx.xxx...Done
Removing files from /dev/shm...Done
PING xxx.xxx.xxx.xxx (xxx.xxx.xxx.xxx): 56 data bytes
64 bytes from xxx.xxx.xxx.xxx: icmp_seq=0 ttl=55 time=36.273 ms
64 bytes from xxx.xxx.xxx.xxx: icmp_seq=1 ttl=55 time=36.838 ms
64 bytes from xxx.xxx.xxx.xxx: icmp_seq=2 ttl=55 time=38.689 ms
```

Leave this ping running! You'll want it to show host isolation later.

You may need to manually run these two detection rules, as they run once an hour and may not run on their normal schedule before time to give the demo:

* Account or Group Discovery via Built-In Tools
* Linux System Information Discovery

Now you're ready to start investigating alerts (well, once your detection rules have all run)! Navigate to the Alerts page and you should see quite a few alerts that have been triggered:

![Alerts view](screenshots/es-sec-demo_alerts_view.png)

Ensure that building block alerts are selected in "Additional filters":

![Building block alerts](screenshots/es-sec-demo_building_blocks.png)

Now you can talk through whatever normal flow you like when demoing Security, but when you get ready to investigate an alert, here is a demo flow that I tend to use. I think it shows well:

1. Select the Linux Restricted Shell Breakout via Linux Binary(s) alert and talk through some of the alert details.
2. Bring up the Event Analyzer. The binaries used in this repo generated some user/filessytem activity through a specific process ancestry:

![Event Analyzer](screenshots/es-sec-demo_event_analyzer.png)

Be sure to also go all the way to the end of the process ancestry (all the way at the top right) and talk about the 'rm' command being run, and how it looks like someone may have tried to cover their tracks by removing the binary from disk (this will set up an OSquery investigation later).

![Remove command](screenshots/es-sec-demo_remove_command.png)

3. Talk about Cases, Session View or whatever else you feel is necessary here, then move to taking some kind of action. Now would be a good time to isolate the host and bring up the terminal window on your local machine showing the running ping to the TARGET_HOST:

![Host isolation](screenshots/es-sec-demo_isolate_host.png)

4. Now you can pull up OSquery and run the query in osquery/osquery_find_deleted_processes:

   ```sql
   SELECT pid, name, path, cmdline, on_disk 
   FROM processes 
   WHERE on_disk = 0;
   ```
   _NOTE: You can save this query as a saved query in OSquery Manager so that it's always available without having to copy-pasta._

This will find running processes that have been deleted from disk but are still running in memory:

![Deleted processes still running](screenshots/es-sec-demo_deleted_processes_running.png)

5. From here, the world is really your oyster. There are response action scripts in response/ that you can use to show executing scripts while the host is still isolated. This repo also creates enough noise and enough activity to have a decent showing with Attack Discovery, so be sure to go that route, too:

![Attack Discovery](screenshots/es-sec-demo_attack_discovery.png)

<!-- FINAL THOUGHTS -->
## Final Thoughts
This is something I've been using for a few years now and it always seems to show well, so I wanted to share this with anyone who might get some value from it. Sometimes it's nice to have an environment that you control, rather than a canned demo environment that you don't have the permissions to show things when the customer asks questions outside of the demo flow. I hope you find value in it too, and please feel free to contribute...there's plenty of room for improvement and enhancement here!

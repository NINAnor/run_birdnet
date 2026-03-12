# Running BirdNET in NINA

This repository contains the scripts to run BirdNET very easily for any project.

# Requirements

**Python dependancies:**

```bash
uv install
```

**system dependancies:**

- `GNU Parallel`
- `Rclone` (only if using `run_birdnet_remote_rclone.sh`)

> [!WARNING]
> If running on a NINA CPU server, remember to use `kinit`

# Usage

1. Clone this repository.
2. Change the `.env` with the project .
3. start `run_birdnet_parallel.sh` if data local or `run_birdnet_remote_rclone.sh` if data on an S3 bucket.
4. Get your results!

> [!TIP]
> The scripts use the `--resume` function of `GNU Parallel`, meaning that a `.log` is created for all the files analyzed. If the process stops, the scripts will restart where the process has stopped.

# Workaround `kinit` stoppage

Because we need to renew the **Kerberos ticket-granting ticket**, there can be a stoppage when trying to analyze large dataset (e.g. the ticket is valid for 10 hours on `t2lipcpi02.nina.no`). We need to run `kinit` every once in a while by setting up a `cron` job.

After running `kinit` and fill in your password you can find a **credential cache (krb*)**. This contains credentials used to run `kinit` without more manual authentification (up to a certain limit, that you can figure out with `klist`).

To setup the cronjob, use `crontab -e` and add the following line:

```bash
* * * * * KRB5CCNAME=/tmp/krb5cc_210015162 kinit -R
```

This should run `kinit` every minute without any manual intervention.

# Contact me

Benjamin Cretois
benjamin.cretois@nina.no

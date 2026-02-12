# Running BirdNET in NINA

This repository contains the scripts to run BirdNET very easily for any project.

# Requirements

Install the dependancies

```bash
uv install
```

Also install `GNU Parallel` for running `run_birdnet_parellel.sh`

> [!WARNING]
> If running on a NINA CPU server, remember to use `kinit`

# Usage

1. Clone this repository
2. Change the `.env` with the project 
3. start the `run_birdnet_parallel.sh` script
4. Get your results!


# TODO:

Run BirdNET if the files are located on a remote server. Test the `run_birdnet_rclone.sh`

# Contact me

Benjamin Cretois
benjamin.cretois@nina.no
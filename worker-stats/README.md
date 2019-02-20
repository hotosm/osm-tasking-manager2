# worker-user-stats

A small worker script to generate OSM user statistics from the HOTOSM Tasking Manager database. 

### Overview 

This script generates timestamp data for users who have used the HOTOSM tasking manager. Specifically, edit timestamps in the categories of done, validated, and invalidated, arranged by project and by user. For example:

```
"2156(userid)": {
  "167(projectid)": {
    "done": {
      "times": [
        "Sat Feb 13 2016 04:58:03 GMT"
        "Sat Feb 20 2016 04:02:20 GMT"
        "Sat Jan 30 2016 17:50:38 GMT"
      ]
    },
    "invalidated": {
      "times": [
        "Sun Apr 10 2016 08:24:42 GMT"
        "Thu Mar 03 2016 06:17:58 GMT"
      ]
    },
    "validated": {
      "times": [
        "Sun Jan 31 2016 07:16:41 GMT"
        "Thu Feb 11 2016 08:09:27 GMT"
        "Mon May 09 2016 02:25:27 GMT"
        "Thu Apr 14 2016 06:37:59 GMT"
        "Wed Mar 09 2016 19:44:51 GMT"
        "Wed May 25 2016 04:40:04 GMT"
      ]
    }
  }
}
```

The script generates JSON and posts to an Amazon S3 bucket to be served as static JSON endpoint. 

## Usage

To be run as a worker alongside the Tasking Manager every 10 mins. 

```
$ pip install -r requirements.txt
$ python user-stats.py
```

## Requirements

- Read access to the Tasking Manager database
- Amazon S3 bucket with public read access
- Amazon S3 write credentials. See `users-stats.py` for environment variables. 

### Environment variables

- `S3_ACCESS_KEY=your_access_key`
- `S3_SECRET_KEY=your_secret_key`
- `BUCKET=your_bucket`

#!/usr/bin/python

# This script creates statistics for OSM users of the OSM Tasking Manager database. 
# Edit timestamps for each category of action arranged by project and user. 
# Output is in JSON format and is uploaded directly to an Amazon S3 bucket.
#
# Environment variables:
#
#   S3_ACCESS_KEY=your_access_key
#   S3_SECRET_KEY=your_secret_key
#   BUCKET=your_bucket
#
# Usage
#
# python user-stats.py

import psycopg2
import psycopg2.extras
import tinys3
import simplejson as json
from datetime import datetime
import time
import os

def connectDB():
    # login info
    host = 'localhost'
    database = 'osmtm'
    user = 'postgres'
    # define connection string
    conn_string = "host='%s' dbname='%s' user='%s'" % (host, database, user)
    # get a connection
    conn = psycopg2.connect(conn_string)
    # initialize a cursor
    return conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)

# returns dictionary of users, their projects, the categories of edits
# made by them, and the times they made those edits
def getTaskstate():
    # connect to database
    cur = connectDB()
    # cursor to select all relevant task_state columns
    cur.execute(' SELECT user_id, project_id, state, date \
                  FROM task_state \
                  WHERE user_id IS NOT NULL \
                  AND state IN (1, 2, 3) ')
    records = cur.fetchall()
    # build user dictionary with unique keys and subkeys for user_id and
    # project_id, and placeholders for edit type and times
    stateLookup = {2: 'done', 3: 'validated', 1: 'invalidated'}
    users = {}
    # loop through all records from database query to generate per user data
    for r in records:
        user_id = str(r.user_id)
        proj_id = str(r.project_id)
        # create empty dict for each user
        users[user_id] = {}
        # check if user exists in the users dict
        if user_id in users:
            if proj_id in users[user_id]:
                users[user_id][proj_id][stateLookup[r.state]]['times']\
                    .append(str(r.date).split(".")[0])
            else:
                users[user_id][proj_id] = {'done': {'times': []},
                                           'validated': {'times': []},
                                           'invalidated': {'times': []}}

    return users

def upload(file):
    # uses tinys3 to create connection, open file, and upload
    # get access keys and buckets from environment variables
    conn = tinys3.Connection(os.getenv('S3_ACCESS_KEY'), os.getenv('S3_SECRET_KEY'), tls=True)
    f = open('%s.json' % file, 'rb')
    conn.upload('%s.json' % file, f, bucket=os.getenv('BUCKET'), content_type='application/json')

def main():
    users = getTaskstate()

    # dump users dict into minified json
    fout = json.dumps(users, separators=(',',':'))
    # generate file of users json
    f = open('users.json', 'wb')
    f.write(fout)
    f.close()
    # trigger upload to s3
    upload('users')

if __name__ == '__main__':
    main()
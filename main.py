from boto.s3.connection import S3Connection


c = S3Connection('AKIAJGXOUCK7YQMJ374Q', 'T5Dngsuxb952DhFElV4yk4bPGn2F++c4pSKCYuER')

rs = c.get_all_buckets()
for b in rs:
    print b.name
    for x in dir(b):
        print x
    print b.get_all_keys()

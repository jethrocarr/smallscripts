#!/usr/bin/python
#
# Twitter Auto-Delete Script
#
# This script runs through a twitter stream and automatically deletes any posts
# older than the defined number of hours.
#

import time
import re
import twitter


# application
app_consumer_key	= ''
app_consumer_secret	= ''

# configuration
user_name		= '@example'
user_token_key		= ''
user_token_secret	= ''

# query options
query_quantity		= 200

# time options
cond_time_hours		= 24
cond_time_seconds	= cond_time_hours * 60 * 60
cond_time_before	= time.time() - cond_time_seconds


# authenticate
api = twitter.Api()
api = twitter.Api(consumer_key=app_consumer_key,consumer_secret=app_consumer_secret, access_token_key=user_token_key, access_token_secret=user_token_secret)




# query my user status list
mytimeline = api.GetUserTimeline(screen_name=user_name,count=query_quantity,include_rts=True)

for status in mytimeline:

	if re.match("^New Blog Post", status.text):
		#print "Blog post! No delete wanted"
		continue

	if status.created_at_in_seconds < cond_time_before:
		api.DestroyStatus(status.id)
	
		print "Deleting Tweet:"
		print "- Created At: " + status.created_at
		print "- Content: " + status.text




# query my user favourites list
myfavorites = api.GetFavorites()

for favorite in myfavorites:

		api.DestroyFavorite(favorite)

		print "Unfavoriting Tweet:"
		print "- Created At: " + favorite.created_at
		print "- Content: " + favorite.text
	




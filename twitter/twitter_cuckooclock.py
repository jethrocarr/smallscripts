#!/usr/bin/python
#
# Twitter Cuckoo Clock
#
# I'm a clock! Squawk!
#

import time
import sys
import random
import twitter

# application
app_consumer_key	= ''
app_consumer_secret	= ''

# configuration
user_name		= '@example'
user_token_key		= ''
user_token_secret	= ''



# authenticate
api = twitter.Api()
api = twitter.Api(consumer_key=app_consumer_key,consumer_secret=app_consumer_secret, access_token_key=user_token_key, access_token_secret=user_token_secret)


# generate the cuckoo message
time_hour = int( time.strftime("%I") )
message = 'cuckoo! '

i = 1
while i < time_hour:
	i += 1
	message	+= ' cuckoo!'


# Perform sanity checks
#

mytimeline = api.GetUserTimeline(screen_name=user_name,count=1)

for status in mytimeline:

	last_time = status.text.count("cuckoo!")

	# basic sanity check - check if the last status update message is the same as
	# the next one, if so we should avoid posting as it might be sign of a cron
	# execution fault.

	if last_time == time_hour:
		print "Twitter cuckoo clock error: duplicate cuckoo! Cron job may be running too frequently."
		sys.exit(0)


	# time jump sanity check - check if the clock has gone forwards/back in time, which
	# can happen after a server/twitter outage OR during daylight savings changes. We
	# wouldn't want people to think we're a buggy cuckoo!

	# should prob write this ;-)	


# Cuckoo the time!
#
api.PostUpdate(message)


# Introduce random probability of displaying one of the additional strings with a
# one-in-10-chance

bonus_rand = random.randint(1,10)

bonus_messages = [ 'Additional cuckoo error in your favour.',
				'Pop little birdy out.',
				'*speak in the tongues of the dammed*',
				'Randomly flap door open',
				'Open flap door. Emit dust ball.',
				'Startle cat.',
				'Creak slightly.',
				'Wish I was a rooster.',
				'CUCKOO HAS NO SNOOZE MODE. CUCKOO NEEDS NO SNOOZE MODE!',
				'Wake guest with a sudden frightning jolt.',
				'Survive violent aggressions by house occupants. Continue to cuckoo.',
				'Cuc-cuc-cuc-cuc-cuc-cuc-kooo',
				'Meow! Err, I mean cuckoo.',
				'Interrupt sexy-times at awkward climax.',
				'Cuckoos moments before crazy in-laws phone',
				'Wage undying war on the oven clock. Triggers power blackout.',
				'Goes all night long. Even with your mum.',
				'Has wood.',
				'Time is relative to how hungry the cuckoo is.',
				'Open door. Make rusty hinge of death sound.' ]


if bonus_rand == 10:

	# post random choice of bonus message
	bonus_rand2 = random.randint(1, len(bonus_messages) );
	api.PostUpdate( str( bonus_messages[ bonus_rand2 ] ) )



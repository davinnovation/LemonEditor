#!/usr/bin/expect -f

#  scp_download.sh
#  IUEditor
#
#  Created by seungmi on 2014. 7. 29..
#  Copyright (c) 2014년 JDLab. All rights reserved.

set from [lrange $argv 0 0]
set user [lrange $argv 1 1]
set server [lrange $argv 2 2]
set remoteDirectory [lrange $argv 3 3]
set syncdir [lrange $argv 4 4]
set password [lrange $argv 5 5]


spawn sh -c "scp -rp $user@$server:$remoteDirectory/* $from/$syncdir/*"
match_max 100000

# Look for passwod prompt
expect {
"*?assword:*" {
# Send password aka $password
send -- "$password\r"

# send blank line (\r) to make sure we get back to gui
send -- "\r"
}
}

expect eof
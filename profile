ndb/cs
ndb/dns
load std
mkdir -p /mnt/keys
echo ----- /lib/sh/profile
load std
load file2chan 
output_file := /tmp/output_file

test -d /youtube || mkdir -p /youtube
test -d /subs || mkdir -p /subs
touch /youtube/ctl /youtube/result
test -d /tmp || mkdir -p /tmp
test -d /tmp/file2chan || mkdir -p /tmp/file2chan
test -d /tmp/users || mkdir -p /tmp/users            
  


file2chan /tmp/file2chan/cmd {
      if {~ ${rget offset} 0} {
              cat $output_file | putrdata
            } {
                    rread ''
                  }
    } {
          sh -n -c ${rget data} > $output_file >[2=1]
     }

mkdir -p /n/client   

listen -v -t -A 'tcp!*!1917' { export / & }

echo --- finish loading profile